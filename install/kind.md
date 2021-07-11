# kind

[kind官网](https://kind.sigs.k8s.io/)

### 安装部署

```sh
# node网络处理(默认172.17.0.0/16与公司网络冲突)
# yum -y install bridge-utils
# 创建一个网桥
brctl addbr ad0 eth0
# 给网桥占位IP地址
ifconfig ad0 172.17.0.1
# 删除占位网桥(待 kind 初始化完毕以后)
ifconfig ad0 down
brctl delbr ad0

# 1、安装 kubectl(略)
# curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.21.1/bin/linux/amd64/kubectl
curl -LO  http://10.0.43.24:8066/k8s/kubectl/v1.21.1/kubectl
chmod +x ./kubectl
mv ./kubectl /usr/local/bin/kubectl
# 2、安装 docker(略)
# 3、安装 kind
# curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.11.1/kind-linux-amd64
curl -Lo ./kind http://10.0.43.24:8066/package/kind/v0.11.1/kind-linux-amd64
chmod +x ./kind
mv ./kind /usr/local/bin/kind
kind version
# 4、初始化集群
kind create cluster --config kind.yaml
# Creating cluster "kind" ...
#  ✓ Preparing nodes   e (kindest/node:v1.21.1) [?7l
#  ✓ Joining worker nodes Set kubectl context to "kind-kind"
# You can now use your cluster with:
# 
# kubectl cluster-info --context kind-kind
# 
# Thanks for using kind!
# 5、切换 kubectl 集群上下文
kubectl cluster-info --context kind-kind
# 6、查看集群
kubectl get node
kind get clusters

# 通过 docker exec kind-control-plane crictl ps 获取这个容器内部的运行容器列表，这个容器内部通过 crictl 来操作容器
docker exec kind-control-plane crictl ps

# 查看镜像
docker exec -it kind-control-plane crictl images
docker exec -it kind-worker crictl images

# 本地装载镜像(注意 imagePullPolicy: IfNotPresent)
kind load docker-image hub.wonhigh.cn/tools/nginx:1.17.10-0602 hub.wonhigh.cn/tools/nginx:1.17.10-0602

# 使用私仓(暂未成功，拉不下来镜像)
kubectl create secret docker-registry regcred \
  --docker-server=hub.wonhigh.cn \
  --docker-username=readonly \
  --docker-password=Readonly2018 \
  --docker-email=readonly@ex.com
kubectl get secret regcred --output=yaml
kubectl get secret regcred --output="jsonpath={.data.\.dockerconfigjson}" | base64 --decode

# 查看私仓配置
docker exec -it kind-control-plane cat /etc/containerd/config.toml
docker exec -it kind-worker cat /etc/containerd/config.toml

# 测试集群
kubectl apply -f test.yaml
kubectl get pod
kubectl port-forward service/nginx 8080:80
curl http://localhost:8080
kubectl proxy --port=8080 --address='10.0.30.199' --accept-hosts='^10.0.30.199$'

# 删除集群(如果未指定标志 -- name，kind 将使用默认的集群上下文名称 kind 并删除该集群)
# kind delete cluster
```

kind.yaml

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
networking:
  # 暴露API地址
  apiServerAddress: "10.0.30.199"
  podSubnet: "10.244.0.0/16"
  serviceSubnet: "10.96.0.0/12"
  ipFamily: ipv4
containerdConfigPatches:
- |-
  [plugins."io.containerd.grpc.v1.cri".registry.mirrors."hub.wonhigh.cn"]
    endpoint = ["http://hub.wonhigh.cn"]
  [plugins."io.containerd.grpc.v1.cri".registry.configs."hub.wonhigh.cn".tls]
    insecure_skip_verify = true
  [plugins."io.containerd.grpc.v1.cri".registry.mirrors."docker.io"]
    endpoint = ["https://registry.docker-cn.com"]
# 1 control plane node and 3 workers
nodes:
# the control plane node config
- role: control-plane
  extraMounts:
  - containerPath: /var/lib/kubelet/config.json
    hostPath: /root/.docker/config.json
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
# the three workers
- role: worker
  extraPortMappings:
  - containerPort: 80
    hostPort: 8080
    listenAddress: "0.0.0.0" # Optional, defaults to "0.0.0.0"
    protocol: tcp # Optional, defaults to tcp
  extraMounts:
  - containerPath: /var/lib/kubelet/config.json
    hostPath: /root/.docker/config.json
  - containerPath: /data
    hostPath: /data/docker_volumn/work_data
# - role: worker
# - role: worker
```

test.yaml

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx
  name: nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      imagePullSecrets:
      - name: regcred
      containers:
      - name: nginx
        image: nginx
        # image: hub.wonhigh.cn/tools/nginx:1.17.10-0602
        imagePullPolicy: IfNotPresent
        volumeMounts:
          - mountPath: /data
            name: test-path
      volumes:
      - hostPath:
          path: /data
          type: ""
        name: test-path
---
apiVersion: v1
kind: Service
metadata:
  name: nginx
spec:
  ports:
  - name: 80-tcp
    port: 80
    protocol: TCP
    targetPort: 80
  selector:
    app: nginx
  type: ClusterIP
```

[kind-example-config.yaml](https://raw.githubusercontent.com/kubernetes-sigs/kind/master/site/content/docs/user/kind-example-config.yaml)

### 设置代理-宿主机

```sh
export http_proxy="http://10.234.6.219:8118"
export https_proxy="http://10.234.6.219:8118"
export no_proxy="localhost,172.17.0.0/16,192.168.0.0/16.,127.0.0.1,10.10.0.0/16,10.0.0.0/16,gitlab.wonhigh.cn,hub.wonhigh.cn"
export HTTP_PROXY="http://10.234.6.219:8118"
export HTTPS_PROXY="http://10.234.6.219:8118"
export NO_PROXY="localhost,172.17.0.0/16,192.168.0.0/16.,127.0.0.1,10.10.0.0/16,10.0.0.0/16,gitlab.wonhigh.cn,hub.wonhigh.cn"

# 验证代理
curl -I www.google.com

mkdir -p /etc/systemd/system/docker.service.d

echo '
[Service]
Environment="HTTP_PROXY=http://10.234.6.219:8118" "NO_PROXY=localhost,172.17.0.0/16,172.18.0.0/16,192.168.0.0/16.,127.0.0.1,10.10.0.0/16,10.0.0.0/16,gitlab.wonhigh.cn,hub.wonhigh.cn"
' | tee /etc/systemd/system/docker.service.d/http-proxy.conf
systemctl daemon-reload && systemctl restart docker

# 取消代理
export http_proxy=""
export https_proxy=""

echo '' | tee /etc/systemd/system/docker.service.d/http-proxy.conf
systemctl daemon-reload && systemctl restart docker
```

### 设置代理-容器内

[Configure Docker to use a proxy server](https://docs.docker.com/network/proxy/#use-environment-variables)

```sh
#  新增或者修改 vi ~/.docker/config.json ，增加以下内容
"proxies":
 {
   "default":
   {
     "httpProxy": "http://10.234.6.219:8118",
     "httpsProxy": "http://10.234.6.219:8118",
     "noProxy": "localhost,172.17.0.0/16,172.18.0.0/16,192.168.0.0/16,127.0.0.1,10.10.0.0/16,10.0.0.0/16,172.17.191.26,*.wonhigh.cn,kind-control-plane,*.lesoon.com,*.svc,*.belle.net.cn"
   }
 }
```

### 安装一些工具

操作系统实际上是ubuntu的。

```sh
docker exec -it kind-worker bash
apt-get update
apt-get install -y net-tools iputils-ping
```

### ingress测试

```sh
export http_proxy="http://10.234.6.219:8118"
export https_proxy="http://10.234.6.219:8118"
wget https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.47.0/deploy/static/provider/kind/deploy.yaml
export http_proxy=""
export https_proxy=""

kubectl apply -f deploy.yaml 
```

### 参考资料

[比Minikube更快，使用Kind快速创建K8S学习环境](https://www.cnblogs.com/ants/p/13217451.html)

[使用 KinD 加速 CI/CD 流水线](https://jishuin.proginn.com/p/763bfbd2e61b)

[使用 KinD 加速 CI/CD 流水线](https://cloud.tencent.com/developer/article/1729498)

[使用kind搭建kubernetes](https://www.cnblogs.com/charlieroro/p/13711589.html)

[如何配置docker使用HTTP代理](如何配置docker使用HTTP代理)

[Configure Image Registry](https://github.com/containerd/cri/blob/master/docs/registry.md)

[Containerd cannot pull image from insecure registry](https://github.com/containerd/containerd/issues/3847)
