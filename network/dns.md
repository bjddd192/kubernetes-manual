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

## 未容器化之前的现状

### 上线之前的问题（部署问题）

据了解，开发除了完成自己的开发任务以外，在上线前，需要对自己开发的应用写一个详细的安装说明，来告诉测试、运维如何部署。

不过，即便如此，仍然常常会发生部署失败或者出错的情况，可能有以下原因：

1. 安装说明是基于开发环境编写，且可能写的不够详细，导致配置错误或者步骤遗漏；
2. 部署人员水平的高低不同，特别是测试环境部署人员通常不是专业运维，不了解原理，依葫芦画瓢更容易出错；
3. 运维针对安装说明做了部署上的微调，却没搞清楚应用之间的环境配置依赖问题；

导致的后果（互相指责，推卸责任）：

1. 开发对测试、运维不信任（给了文档还老出问题，不如我自己上了）；
2. 测试、运维责备开发人员文档没写好（把开发抓过来先把环境跑起来再说）；
3. 开发很不爽，反正我的应用没问题，它在开发环境跑的顺溜的很；
4. 增加了各部门人员之间的沟通成本；
5. 最终环境跑起来了，但是完整的文档是没有的；

### 上线之后的问题（运维问题）

#### 运维噩梦--克隆移植噩梦

1. 老板：这套产品A事业部觉得很好用，B事业部也很想用，XX时间就想要，咱们赶紧给B部门再部署一套吧；
2. 测试：上线这么久了，测试环境与生产环境差异挺大的，能不能帮克隆一套环境到过来做测试；
3. 开发经理：最近开发做了重大调整，为了确保安全，需要在生产部署一套全新的环境来进行灰度发布；
4. 运维经理：这批机器老化了，需要升级，今晚准备做一把迁移吧；

运维：尼玛，昨晚又通宵了。

#### 运维噩梦--资源利用率低

机器资源利用率低
单机多应用无法有效隔离（cpu、内存、硬盘）
开发、测试版本管理复杂
迁移成本高
补丁环境、体验环境

### 追究原因

应用 环境 脱离

### 如何解决呢？

应用如果能带着环境走就好了，就像我们在 windows 下常用的绿色软件一样，放到 u 盘里面到哪里都能用。

### 带环境安装解决方案

使用虚拟化技术，将应用与环境打包到一起。

主要有2种技术：

1. 虚拟机（virtual machine）
2. Linux容器（Linux container，缩写为LXC）

### 学习容器的好处

可以快速使用已经容器化的产品，比如 gitlab、mysql、oracle、redis 等，不需要关心部署过程，不需要关心语言环境

可以将重复的工作容器化，比如 lantern、mycat、otter、jmeter

可以轻松拥有各种学习环境

## 使用容器化以后对各职能的影响

开发：
测试：
运维：


