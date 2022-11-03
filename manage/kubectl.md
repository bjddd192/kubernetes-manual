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

### 常用操作

```sh
# 查看节点资源耗用情况
kubectl top node
# 按 label 查看节点资源耗用情况
kubectl top node -l k8s.wonhigh.cn/namespace=wonhigh-petrel-dev

# 禁止节点调度
kubectl cordon 10.250.11.179
# 驱逐节点 pod
kubectl drain 10.250.11.179 --ignore-daemonsets --delete-local-data
# 强制驱逐节点 pod
kubectl drain 10.250.11.179 --ignore-daemonsets --delete-local-data --force

systemctl stop kubelet
systemctl stop docker

# 关闭服务、重启机器...
# 检查机器...
# 删除已退出的所有容器
docker rm `docker ps -a | grep Exited | awk '{print $1}'` 

# 恢复节点调度
kubectl uncordon 10.250.11.179

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
kubectl -n belle-logistics-prod scale rc logistics-wms-city-yg.2.4.0-sp1.rc1 --replicas=5

# 查看 pod 重启次数
kubectl get pod --all-namespaces -o=wide | grep -v prometheus-k8s | awk '{if($5>0)print($0)}'
# 生成重启 pod 命令
kubectl get pod --all-namespaces -o=wide | grep -v prometheus-k8s | grep -v NAMESPACE | awk '{if($5>0)print("kubectl -n "$1" delete pod "$2)}'
kubectl get pod --all-namespaces -o=wide | grep 0/ | awk '{if($5>6)print("kubectl -n "$1" delete pod "$2)}'
# 获取最近部署的 pod（分钟级）
kubectl get pod --all-namespaces -o=wide | awk '{if($6~"m")print($0)}'

# 强制重启 pod
kubectl -n belle-petrel-prod get pod wms-e-all-api-6c447ddcf6-7lwx9 -o=yaml | kubectl replace --force -f -

# 重启 ns 下所有 pod
kubectl get pod -n belle-scm-press -o=wide | grep -v prometheus-k8s | grep -v NAMESPACE | awk '{if(1>0)print("kubectl -n belle-scm-press delete pod "$1)}'

kubectl get pod -n lesoon-dev | grep api | awk '{if(1>0)print("kubectl -n lesoon-dev delete pod "$1)}'

# 停止容器服务
systemctl stop kubelet && systemctl stop docker && systemctl status docker

# 导出堆栈脚本
export DUMP_APP=wms-api-77f565f756-vkfvt
kubectl -n belle-petrel-prod exec -it $DUMP_APP bash

# 导出堆栈
cd /tmp
rm -rf /tmp/app.dump
export pid=`ps | grep java | grep -v grep | awk '{print($1)}'`
jmap -dump:format=b,file=/tmp/app.dump $pid
exit

# 压缩
kubectl -n belle-petrel-prod cp $DUMP_APP:/tmp/app.dump /tmp/$DUMP_APP.dump
zip -r /tmp/$DUMP_APP.zip /tmp/$DUMP_APP.dump
sz /tmp/$DUMP_APP.zip
scp /tmp/$DUMP_APP.zip 10.250.15.49:/data/sfds/tmp/

kubectl -n lesoon-dev -c logistics-dop-server-api cp logistics-dop-server-api-v1-864df8ff88-xvtb2:/tmp/app.dump /tmp/dop.dump

# 查看java进程
kubectl -n belle-petrel-prod exec -it  oms-check-api-847c854f6-vsdbs -- ps -ef  | grep java | awk '{print $1}'
```

```sh
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

### k8s中pod的容器日志查看命令

如果容器已经崩溃停止，您可以仍然使用 kubectl logs --previous 获取该容器的日志，只不过需要添加参数 --previous。 如果 Pod 中包含多个容器，而您想要看其中某一个容器的日志，那么请在命令的最后增加容器名字作为参数。

```sh
# 追踪名称空间 nsA 下容器组 pod1 的日志
kubectl logs -f pod1 -n nsA

# 追踪名称空间 nsA 下容器组 pod1 中容器 container1 的日志
kubectl logs -f pod1 -c container1 -n nsA

# 查看容器组 nginx 下所有容器的日志
kubectl logs nginx --all-containers=true

# 查看带有 app=nginx 标签的所有容器组所有容器的日志
kubectl logs -lapp=nginx --all-containers=true

# 查看容器组 nginx 最近20行日志
kubectl logs --tail=20 nginx

# 查看容器组 nginx 过去1个小时的日志
kubectl logs --since=1h nginx
```

### 不常用操作

```sh
# dns 组件检查
kubectl get endpoints kube-dns -n kube-system 
kubectl exec -it kube-dns-84777cd667-84hzf -c kubedns -n kube-system nslookup kubernetes.default 127.0.0.1
kubectl exec -it kube-dns-84777cd667-84hzf -c kubedns -n kube-system nslookup test-dop-server.belle.net.cn 127.0.0.1
kubectl exec -it kube-dns-84777cd667-jg5f9 -c kubedns -n kube-system nslookup test-dop-server.belle.net.cn 127.0.0.1
kubectl exec -it kube-dns-84777cd667-p8bvd -c kubedns -n kube-system nslookup test-dop-server.belle.net.cn 127.0.0.1
kubectl exec -it kube-dns-84777cd667-pnsnm -c kubedns -n kube-system nslookup test-dop-server.belle.net.cn 127.0.0.1
kubectl exec -it kube-dns-84777cd667-sbk5k -c kubedns -n kube-system nslookup test-dop-server.belle.net.cn 127.0.0.1

# 删除 deployment 时保留 pod
kubectl -n belle-scm-press delete deployment pm-smd-bizrec-api --cascade=false

# 双横线分隔要在容器内执行的命令
kubectl -n belle-scm-press exec pm-smd-bizrec-api-6dff75cdd5-jz528 -- curl -s http://www.baidu.com

# 获取所有节点的 ExternalIP
kubectl -n belle-logistics-uat get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="ExternalIP")].address}'

# 快速创建一个dns查询pod
kubectl run dnsutils --image=tutum/dnsutils --generator=run-pod/v1 --command -- sleep infinity 
kubectl exec dnsutils -- nslookup oms-web.belle-petrel-uat

# 批量删除 Evicted Pods
/usr/bin/kubectl -n kube-system get pods | grep Evicted | awk '{print$1}' | xargs kubectl -n kube-system delete pod
/usr/bin/kubectl -n default get pods | grep Evicted | awk '{print$1}' | xargs kubectl -n default delete pod

# 批量删除 Evicted Pods(扫描全部命名空间)
kubectl get pod --all-namespaces | grep Evicted | awk '{print$1} {print$2}' | xargs -n 2 bash -c 'echo "kubectl -n $0 delete pod $1"'
kubectl get pod --all-namespaces | grep Evicted | awk '{print$1} {print$2}' | xargs -n 2 bash -c 'kubectl -n $0 delete pod $1'
```

## 参考资料

[Overview of kubectl](https://kubernetes.io/docs/reference/kubectl/overview/)

[Mac中使用brew安装指定版本软件包](https://segmentfault.com/a/1190000015346120?utm_source=tag-newest)

[kubectl技巧之通过jsonpath截取属性](https://www.cnblogs.com/tylerzhou/p/11049050.html)

[Kubernetes Docker 常用命令](https://www.cnblogs.com/xiangsikai/p/9995385.html)
