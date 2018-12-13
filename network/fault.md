# 网络故障

## node 上的容器无法解析内网 dns，公网地址可以解析

现象：node 的宿主机可以解析 hosts，node 上的容器无法解析内网 dns，集群内其他的 node 节点无此问题。

问题分析：

```sh
# 检查集群的 dns 组件
kubectl get pod --all-namespaces -o=wide | grep dns

# 发现宿主机和 dns 容器的域名解析都是指向 nameserver 114.114.114.114，问题可想而知
cat /etc/resolv.conf
```

解决办法：

```sh
# 修改 kubedns.yaml 的 kube-dns ConfigMap，增加 stubDomains 自定义的域名解析
apiVersion: v1
kind: ConfigMap
metadata:
  name: kube-dns
  namespace: kube-system
  labels:
    addonmanager.kubernetes.io/mode: EnsureExists
data:
  stubDomains: |
    {"belle.cn": ["172.20.32.132"], "belle.net.cn": ["172.20.32.132"]}
```

### 参考资料

[如何给kube-dns插一条自定义的域名记录](https://www.colabug.com/880577.html)

[kubernetes的自定义Dns](https://blog.csdn.net/yinlongfei_love/article/details/80563784)

[Kubernetes之配置与自定义DNS服务](https://blog.csdn.net/dkfajsldfsdfsd/article/details/81218480)
