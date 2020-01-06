# kubelet

## kubelet 的主要功能

kubelet 默认监听四个端口，分别为 10250 、10255、10248、4194

```sh
netstat -nlap | grep LISTEN| grep kubelet
tcp        0      0 10.243.2.165:4194       0.0.0.0:*               LISTEN      24602/kubelet       
tcp        0      0 127.0.0.1:10248         0.0.0.0:*               LISTEN      24602/kubelet       
tcp        0      0 10.243.2.165:10250      0.0.0.0:*               LISTEN      24602/kubelet       
tcp        0      0 10.243.2.165:10255      0.0.0.0:*               LISTEN      24602/kubelet       
unix  2      [ ACC ]     STREAM     LISTENING     115516923 24602/kubelet        /var/run/dockershim.sock

# 10250（kubelet API）：kubelet server 与 apiserver 通信的端口，定期请求 apiserver 获取自己所应当处理的任务，通过该端口可以访问获取 node 资源以及状态。

# 10248（健康检查端口）：通过访问该端口可以判断 kubelet 是否正常工作, 通过 kubelet 的启动参数 --healthz-port 和 --healthz-bind-address 来指定监听的地址和端口。
# curl http://127.0.0.1:10248/healthz

# 4194（cAdvisor 监听）：kublet 通过该端口可以获取到该节点的环境信息以及 node 上运行的容器状态等内容，访问 http://localhost:4194 可以看到 cAdvisor 的管理界面,通过 kubelet 的启动参数 --cadvisor-port 可以指定启动的端口。
# curl  http://127.0.0.1:4194/metrics

# 10255 （readonly API）：提供了 pod 和 node 的信息，接口以只读形式暴露出去，访问该端口不需要认证和鉴权。
# 获取 pod 的接口，与 apiserver 的 
# http://127.0.0.1:8080/api/v1/pods?fieldSelector=spec.nodeName=  接口类似
# curl  http://127.0.0.1:10255/pods
# 节点信息接口,提供磁盘、网络、CPU、内存等信息
# curl http://127.0.0.1:10255/spec/
```

## 常用操作

```sh
# 查看 node 节点证书有效期
openssl x509 -noout -text -in /etc/kubernetes/ssl/kubelet-client.crt
```

## kubelet 证书到期解决方法

kubelete 证书默认有效期一年

```sh
# 安装工具
# curl -s -L -o /bin/cfssl-certinfo https://pkg.cfssl.org/R1.2/cfssl-certinfo_linux-amd64
# chmod a+x /bin/cfssl-certinfo
# 查看证书有效期
cfssl-certinfo -cert /etc/kubernetes/ssl/kubelet.crt
```

### 解决方法一

```sh
# 备份证书
mkdir  ~/sslback && mv /etc/kubernetes/kubelet.kubeconfig  ~/sslback/
# 使用 admin 证书文件替换
cp ~/.kube/config /etc/kubernetes/kubelet.kubeconfig
# 重启服务
systemctl restart kubelet && systemctl status kubelet
```

### 解决方法二

手动签发

在 kubelet 首次启动后，如果用户 Token 没问题，并且 RBAC 也做了相应的设置，那么此时在集群内应该能看到 kubelet 发起的 CSR 请求 ，必须通后 kubernetes 系统才会将该 Node 加入到集群。

```sh
# 在证书过期 node 删除 kubelet 相关证书文件
rm -rf /etc/kubernetes/kubelet.kubeconfig
rm -rf /etc/kubernetes/ssl/kubelet.*
# 重启服务
systemctl restart kubelet && systemctl status kubelet
# 自动生成了 kubelet kubeconfig 文件和公私钥
# 查看未授权的 CSR 请求
kubectl get csr
# 通过CSR 请求：
kubectl certificate approve csr-404fc
# 查看重新生成的证书文件
ll /etc/kubernetes/ssl/kubelet.*
```

## 代办事宜

取消 Node节点 Bootstrap机制，参考 kubeaz

## 参考资料

[kubernetesk kubelet 证书到期解决方法](http://www.idcsec.com/2018/09/21/kubernetesk-kubelet%E8%AF%81%E4%B9%A6%E5%88%B0%E6%9C%9F%E8%A7%A3%E5%86%B3%E6%96%B9%E6%B3%95/)

[kubelet 证书轮换](https://kubernetes.io/zh/docs/tasks/tls/certificate-rotation/)

[kubelet TLS](https://yq.aliyun.com/articles/647345)

[(二进制安装)k8s1.9 证书过期及开启自动续期方案](https://blog.csdn.net/feifei3851/article/details/88390425)

[kubelet 架构浅析](https://www.cnblogs.com/liuhongru/p/11215457.html)