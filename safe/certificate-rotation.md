# 证书轮换

## kubelet证书过期处理方案

集群中某node状态为notReady，apiserver 报错Unable to authenticate the request due to an error: x509: certificate has expired or is not yet valid

### 查看证书有效期

```sh
openssl x509 -in /etc/ssl/k8s/kubelet.crt -noout -text 
```

### 删除kubelet相关证书

在证书过期node节点删除kubelet相关证书文件及配置文件然后重启kubelet,kubelet会向apiserver发起一个csr。

```sh
rm  /etc/kubernetes/kubelet.kubeconfig
rm  /etc/kubernetes/ssl/kubelet.*
```

### 重启kubelet

```sh
systemctl  restart kubelet
systemctl  status  kubelet
```

### apiserver 查看未授权的CSR请求，并授权

```sh
kubectl get csr
#获取到的csr若为csr-4pw6g
kubectl certificate approve csr-4pw6g
```

### 查看node状态

```
kubectl get node
```

Ready则处理完成。

在kubernetes1.7之后，可以采用集群自动签发证书方案，但仍然需要手动重启kubelet, 在1.8之后，就可以自动签发，自动renew证书；也可以设置更长的有效期。

## 开启kubelet证书自动续期

在自动续期下引导过程与单纯的手动批准 CSR 有点差异，具体的引导流程地址如下：

- kubelet 读取 bootstrap.kubeconfig，使用其 CA 与 Token 向 apiserver 发起第一次 CSR 请求(nodeclient)
- apiserver 根据 RBAC 规则自动批准首次 CSR 请求(approve-node-client-csr)，并下发证书(kubelet-client.crt)
- kubelet 使用刚刚签发的证书(O=system:nodes, CN=system:node:NODE_NAME)与 apiserver 通讯，并发起申请 10250 server 所使用证书的 CSR 请求
- apiserver 根据 RBAC 规则自动批准 kubelet 为其 10250 端口申请的证书(kubelet-server-current.crt)
- 证书即将到期时，kubelet 自动向 apiserver 发起用于与 apiserver 通讯所用证书的 renew CSR 请求和 renew 本身 10250 端口所用证书的 CSR 请求
- apiserver 根据 RBAC 规则自动批准两个证书
- kubelet 拿到新证书后关闭所有连接，reload 新证书，以后便一直如此

从以上流程我们可以看出，我们如果要创建 RBAC 规则，则至少能满足四种情况:

- 自动批准 kubelet 首次用于与 apiserver 通讯证书的 CSR 请求(nodeclient)
- 自动批准 kubelet 首次用于 10250 端口鉴权的 CSR 请求(实际上这个请求走的也是 selfnodeserver 类型 CSR)
- 自动批准 kubelet 后续 renew 用于与 apiserver 通讯证书的 CSR 请求(selfnodeclient)
- 自动批准 kubelet 后续 renew 用于 10250 端口鉴权的 CSR 请求(selfnodeserver)

在 1.7 后，kubelet 启动时增加 --feature-gates=RotateKubeletClientCertificate=true,RotateKubeletServerCertificate=true 选项，则 kubelet 在证书即将到期时会自动发起一个 renew 自己证书的 CSR 请求；同时 controller manager 需要在启动时增加 --feature-gates=RotateKubeletServerCertificate=true 参数，再配合相应创建好的 ClusterRoleBinding，kubelet client 和 kubelet server 证才书会被自动签署。

配置 kubelet 自动续期，RotateKubeletClientCertificate 用于自动续期 kubelet 连接 apiserver 所用的证书(kubelet-client-xxxx.pem)，RotateKubeletServerCertificate 用于自动续期 kubelet 10250 api 端口所使用的证书(kubelet-server-xxxx.pem)，–rotate-certificates 选项使得 kubelet 能够自动重载新证书（rotate-certificates参数1.8以后才有，1.7配置自动证书续期后仍需重启kubelet）

### kubelet 配置参数

```
--feature-gates=RotateKubeletClientCertificate=true,RotateKubeletServerCertificate=true
--rotate-certificates=true
```

### kube-controller-manager配置参数

```
--feature-gates=RotateKubeletClientCertificate=true,RotateKubeletServerCertificate=true
--experimental-cluster-signing-duration=87600h0m0s
```

kubelet配置后，controller manager 自动批准相关 CSR 请求，controller manager如果不配置 --feature-gates=RotateKubeletServerCertificate=true 参数，则即使配置了相关的 RBAC 规则，也只会自动批准 kubelet client 的 renew 请求

kube-controller-manager 组件提供了一个 --experimental-cluster-signing-duration 参数来设置签署的证书有效时间；默认为 8760h0m0s，将其改为 87600h0m0s 即 10 年后再进行 TLS bootstrapping 签署证书即可。

### 创建自动批准相关 CSR 请求的 ClusterRole

1.8后 的 apiserver 自动创建了两条 ClusterRole，分别是system:certificates.k8s.io:certificatesigningrequests:nodeclient， system:certificates.k8s.io:certificatesigningrequests:selfnodeclient，还需要创建一条。

```yaml
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: system:certificates.k8s.io:certificatesigningrequests:selfnodeserver
rules:
- apiGroups: ["certificates.k8s.io"]
  resources: ["certificatesigningrequests/selfnodeserver"]
  verbs: ["create"]
```

### ClusterRole绑定到适当的用户组

将 ClusterRole 绑定到适当的用户组，以完成自动批准相关 CSR 请求

此处的system:bootstrappers组与token.csv中的组对应

```sh
#token.csv
ae7cee6997302be28077fcc96c2f5c14,kubelet-bootstrap,10001,"system:kubelet-bootstrap"
#格式 Token,用户名,UID,用户组

# 允许 system:bootstrappers 组用户创建 CSR 请求
kubectl create clusterrolebinding kubelet-bootstrap --clusterrole=system:node-bootstrapper --group=system:kubelet-bootstrap

# 自动批准 system:bootstrappers 组用户 TLS bootstrapping 首次申请证书的 CSR 请求
kubectl create clusterrolebinding node-client-auto-approve-csr --clusterrole=system:certificates.k8s.io:certificatesigningrequests:nodeclient --group=system:kubelet-bootstrap
#注意 clusterrolebinding kubelet-bootstrap及node-client-auto-approve-csr 中的--group=system:kubelet-bootstrap 可以替换为--user=kubelet-bootstrap,与token.csv保持一致。

# 自动批准 system:nodes 组用户更新 kubelet 自身与 apiserver 通讯证书的 CSR 请求
kubectl create clusterrolebinding node-client-auto-renew-crt --clusterrole=system:certificates.k8s.io:certificatesigningrequests:selfnodeclient --group=system:nodes

# 自动批准 system:nodes 组用户更新 kubelet 10250 api 端口证书的 CSR 请求
kubectl create clusterrolebinding node-server-auto-renew-crt --clusterrole=system:certificates.k8s.io:certificatesigningrequests:selfnodeserver --group=system:nodes
```

## kubelet证书介绍

### token.csv

该文件为一个用户的描述文件，基本格式为 Token,用户名,UID,用户组；这个文件在 apiserver 启动时被 apiserver 加载，然后就相当于在集群内创建了一个这个用户；接下来就可以用 RBAC 给他授权；持有这个用户 Token 的组件访问 apiserver 的时候，apiserver 根据 RBAC 定义的该用户应当具有的权限来处理相应请求

### bootstarp.kubeconfig

该文件中内置了 token.csv 中用户的 Token，以及 apiserver CA 证书；kubelet 首次启动会加载此文件，使用 apiserver CA 证书建立与 apiserver 的 TLS 通讯，使用其中的用户 Token 作为身份标识像 apiserver 发起 CSR 请求

### kubelet-client.crt

该文件在 kubelet 完成 TLS bootstrapping 后生成，此证书是由 controller manager 签署的，此后 kubelet 将会加载该证书，用于与 apiserver 建立 TLS 通讯，同时使用该证书的 CN 字段作为用户名，O 字段作为用户组向 apiserver 发起其他请求

### kubelet.crt

该文件在 kubelet 完成 TLS bootstrapping 后并且没有配置 --feature-gates=RotateKubeletServerCertificate=true 时才会生成；这种情况下该文件为一个独立于 apiserver CA 的自签 CA 证书，有效期为 1 年；被用作 kubelet 10250 api 端口

### kubelet-server.crt

该文件在 kubelet 完成 TLS bootstrapping 后并且配置了 --feature-gates=RotateKubeletServerCertificate=true 时才会生成；这种情况下该证书由 apiserver CA 签署，默认有效期同样是 1 年，被用作 kubelet 10250 api 端口鉴权

### kubelet-client-current.pem

这是一个软连接文件，当 kubelet 配置了 --feature-gates=RotateKubeletClientCertificate=true选项后，会在证书总有效期的 70%~90% 的时间内发起续期请求，请求被批准后会生成一个 kubelet-client-时间戳.pem；kubelet-client-current.pem 文件则始终软连接到最新的真实证书文件，除首次启动外，kubelet 一直会使用这个证书同 apiserver 通讯

### kubelet-server-current.pem

同样是一个软连接文件，当 kubelet 配置了 --feature-gates=RotateKubeletServerCertificate=true 选项后，会在证书总有效期的 70%~90% 的时间内发起续期请求，请求被批准后会生成一个 kubelet-server-时间戳.pem；kubelet-server-current.pem 文件则始终软连接到最新的真实证书文件，该文件将会一直被用于 kubelet 10250 api 端口鉴权

## 参考资料

[(二进制安装)k8s1.9 证书过期及开启自动续期方案](https://blog.csdn.net/feifei3851/article/details/88390425)