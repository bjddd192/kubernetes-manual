# minikube

[minikube](https://minikube.sigs.k8s.io/docs/)

[minikube start](https://minikube.sigs.k8s.io/docs/start/)

### 安装步骤

#### centos7

```sh
cd /tmp

# 安装kubectl
wget http://10.250.15.49:8066/k8s-easy/kubectl
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client

# 安装docker
yum -y install docker

# 安装minikube
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# 添加 mini 用户(非root用户可以忽略新增用户步骤)
useradd mini
passwd mini
# groupadd docker
usermod -aG docker mini
# usermod -a -G sudo mini
# centos默认没有sudo组，可以将你的用户指向wheel用户组, wheel用户组同样有sudo权限
usermod -a -G wheel mini
# 赋予docker组
chown root:docker /var/run/docker.sock
# 赋予管理员权限
# echo "root ALL=(ALL) ALL" >> /etc/sudoers

# 启动 minikube(使用国内镜像，大致需要30分钟时间)
su - mini
minikube start --image-mirror-country cn \
--iso-url=https://kubernetes.oss-cn-hangzhou.aliyuncs.com/minikube/iso/minikube-v1.21.0.iso \
--registry-mirror=https://ekj7ys2t.mirror.aliyuncs.com
# 查看pod
minikube kubectl -- get pods -A
minikube kubectl -- describe pod storage-provisioner  -n kube-system
# 发现storage-provisioner镜像拉不下来，需要编辑pod将/k8s-minikube去除
minikube kubectl -- edit pod storage-provisioner  -n kube-system

# 查看下载的镜像，注意需要进入minikube容器内才能查看到哦
docker exec -it minikube bash
# 或者使用
minikube ssh
docker images 

# 安装看板
minikube dashboard
minikube kubectl -- edit deployment kubernetes-dashboard -n kubernetes-dashboard
minikube kubectl -- edit deployment dashboard-metrics-scraper -n kubernetes-dashboard 
minikube dashboard --url
# 异常：Exiting due to SVC_URL_TIMEOUT
# 处理：删除minikube再重新安装
# minikube stop
# minikube delete
# minikube start --image-mirror-country cn --iso-url=https://kubernetes.oss-cn-hangzhou.aliyuncs.com/minikube/iso/minikube-v1.21.0.iso --registry-mirror=https://ekj7ys2t.mirror.aliyuncs.com
* Verifying dashboard health ...
* Launching proxy ...
* Verifying proxy health ...
http://127.0.0.1:45843/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:/proxy/
# 添加集群对外访问代理
nohup kubectl proxy --port=45843 --address='10.244.3.155' --accept-hosts='^10.244.3.155$' >/dev/null 2>&1&
# 最终访问地址：
http://10.244.3.155:45843/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:/proxy

# 部署demo
minikube kubectl -- create deployment hello-minikube --image=registry.cn-hangzhou.aliyuncs.com/google_containers/echoserver:1.4
minikube kubectl -- expose deployment hello-minikube --type=NodePort --port=8080
minikube kubectl -- get services hello-minikube
minikube service hello-minikube
minikube kubectl -- port-forward service/hello-minikube 7080:8080
# 添加对外访问代理
nohup kubectl proxy --port=7080 --address='10.244.3.155' --accept-hosts='^10.244.3.155$' >/dev/null 2>&1&
# 最终访问地址：
http://10.244.3.155:7080/
```

### 参考资料

[Minikube - Kubernetes本地实验环境](https://developer.aliyun.com/article/221687)

[15分钟在笔记本上搭建 Kubernetes + Istio开发环境](https://developer.aliyun.com/article/672675)

[minikube实践篇](https://blog.csdn.net/qq_40499345/article/details/114461596)
