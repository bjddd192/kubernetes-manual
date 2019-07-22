# kubectl

## 安装 kubectl

[Install and Set Up kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

[kube-shell](https://github.com/cloudnativelabs/kube-shell)

[K8S客户端Kubectl无法下载问题的解决办法](https://blog.csdn.net/csdn_duomaomao/article/details/78568551)

[中科大USTC下载](https://mirrors.ustc.edu.cn/kubernetes/apt/pool/)

### mac 安装 kubectl

```sh
brew info kubernetes-cli
brew search kubernetes-cli
brew install kubernetes-cli
brew install bash-completion
kubectl completion bash > $(brew --prefix)/etc/bash_completion.d/kubectl
pip3 install kube-shell

# 卸载
brew uninstall kubernetes-cli

# 指定版本安装(这个安装报错失败)
brew install https://github.com/Homebrew/homebrew-core/blob/d09d97241b17a5e02a25fc51fc56e2a5de74501c/Formula/kubernetes-cli.rb
# 采用二进制方式安装指定版本(需翻墙)
curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.9.6/bin/darwin/amd64/kubectl
chmod +x /Users/yanglei/Downloads/kubectl
mv /Users/yanglei/Downloads/kubectl /usr/local/bin/kubectl
```

将集群的 /root/.kube/config 拷贝到 mac，即可管理集群了。

kubectl label nodes 10.0.43.33 k8s.wonhigh.cn/namespace=bst-petrel-st --overwrite
kubectl label nodes 10.0.43.9  k8s.wonhigh.cn/namespace=bst-petrel-st --overwrite

## 常用操作

```sh
# 查看节点资源耗用情况
kubectl top node
# 按 label 查看节点资源耗用情况
kubectl top node -l k8s.wonhigh.cn/namespace=wonhigh-petrel-dev

# 禁止节点调度
kubectl cordon 10.240.116.53
# 驱逐节点 pod
kubectl drain 10.240.116.53 --ignore-daemonsets --delete-local-data
# 强制驱逐节点 pod
kubectl drain 10.240.116.53 --ignore-daemonsets --delete-local-data --force

# 关闭服务、重启机器...
# 检查机器...
# 删除已退出的所有容器
docker rm `docker ps -a | grep Exited | awk '{print $1}'` 

# 恢复节点调度
kubectl uncordon 10.240.116.53

# 使用 busybox 容器测试集群，比如网络、dns 等是否正常
kubectl run -it --rm busybox2 --image=busybox /bin/sh
kubectl run -it --rm busybox2 --image=busybox --overrides='{ "apiVersion": "apps/v1", "kind": "Deployment", "spec": { "template": { "spec": { "nodeSelector": { "kubernetes.io/hostname": "10.0.42.176" } } } } }' /bin/sh
# 也可以获取官方的编排文件进行改造
wget https://k8s.io/examples/admin/dns/busybox.yaml
kubectl create -f busybox.yaml
kubectl exec -it busybox2 nslookup kubernetes.default
kubectl exec -it busybox3 nslookup kubernetes.default
kubectl exec -it busybox2 nslookup test-dop-server.belle.net.cn
kubectl exec -it busybox3 nslookup test-dop-server.belle.net.cn

kubectl run -it --rm alpine --image=alpine --overrides='{ "apiVersion": "apps/v1", "kind": "Deployment", "spec": { "template": { "spec": { "nodeSelector": { "kubernetes.io/hostname": "10.0.42.176" } } } } }' /bin/sh
apk add curl
apk add tcpdump

# 扩容
kubectl scale deploy kubernetes-dashboard --replicas=1 -n kube-system
kubectl scale rc oms-e-api.1.0.1.rc17 --replicas=3 -n belle-petrel-prod
```

```
重启所有pods
(删除所有pods，然后k8s根据deployment中的设置重建)

kubectl delete pod $(kubectl get pods | grep -v NAME | awk '{print $1}')

更新deployment数量
kubectl scale deployment depName --replicas 1

获取异常容器
kubectl get pods | grep -v Running

查看pod状态信息
kubectl describe pod podName

查看pod日志信息
kubectl logs podName

将k8s node变为不可用状态
kubectl patch node nodeIP -p '{"spec":{"unschedulable":true}}'

将k8s node变为可用状态
kubectl patch node nodeIP -p '{"spec":{"unschedulable":false}}'

```

## 不常用操作

```sh
# dns 组件检查
kubectl get endpoints kube-dns -n kube-system 
kubectl exec -it kube-dns-84777cd667-84hzf -c kubedns -n kube-system nslookup kubernetes.default 127.0.0.1
kubectl exec -it kube-dns-84777cd667-84hzf -c kubedns -n kube-system nslookup test-dop-server.belle.net.cn 127.0.0.1
kubectl exec -it kube-dns-84777cd667-jg5f9 -c kubedns -n kube-system nslookup test-dop-server.belle.net.cn 127.0.0.1
kubectl exec -it kube-dns-84777cd667-p8bvd -c kubedns -n kube-system nslookup test-dop-server.belle.net.cn 127.0.0.1
kubectl exec -it kube-dns-84777cd667-pnsnm -c kubedns -n kube-system nslookup test-dop-server.belle.net.cn 127.0.0.1
kubectl exec -it kube-dns-84777cd667-sbk5k -c kubedns -n kube-system nslookup test-dop-server.belle.net.cn 127.0.0.1
```

## 参考资料

[Overview of kubectl](https://kubernetes.io/docs/reference/kubectl/overview/)

[Mac中使用brew安装指定版本软件包](https://segmentfault.com/a/1190000015346120?utm_source=tag-newest)

