# dns

[Kubernetes之配置与自定义DNS服务](https://blog.csdn.net/dkfajsldfsdfsd/article/details/81218480)

[Kubernetes之DNS](https://blog.csdn.net/dkfajsldfsdfsd/article/details/81209150)

[docker 容器自定义 hosts 网络访问](https://www.chenyudong.com/archives/docker-custom-hosts-network-via-dns.html)

[KubeDNS 架构组成及实现原理](https://hansedong.github.io/2018/11/22/10/)

[Kubernetes DNS 高阶指南](https://juejin.im/entry/5b84a90f51882542e60663cc)

## kubernetes（k8s）DNS 服务反复重启解决

Kube DNS 服务反复重启现象，报错如下：

```sh
k8s.io/dns/pkg/dns/dns.go:150: Failed to list *v1.Service: Get https://10.96.0.1:443/api/v1/services?resourceVersion=0: dial tcp 10.96.0.1:443: getsockopt: no route to host
```

这很可能是 iptables 规则乱了，解决：

```sh
systemctl stop kubelet
systemctl stop docker
iptables --flush
iptables -tnat --flush
systemctl start docker
systemctl start kubelet
```

## 参考资料

[Debugging DNS Resolution](https://kubernetes.io/docs/tasks/administer-cluster/dns-debugging-resolution/)

[Verifying that DNS is working correctly within your Kubernetes platform](https://www.ibm.com/support/knowledgecenter/en/SSYGQH_6.0.0/admin/install/cp_prereq_kubernetes_dns.html)

[kubedns container cannot connect to apiserver](https://github.com/kubernetes/kubeadm/issues/193)

[Kubernetes DNS 高阶指南](http://www.jintiankansha.me/t/Js1R84GGAl)

[/etc/resolv.conf 详解](https://www.cnblogs.com/pzk7788/p/10455150.html)

[Pod 与 Service 的 DNS](https://kubernetes.io/zh/docs/concepts/services-networking/dns-pod-service/)
