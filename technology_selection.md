# 技术选型

## 操作系统选型

[CoreOS，一款 Linux 容器发行版](https://linux.cn/article-8768-1.html)

## 网络组件选型

[Docker网络解决方案-Calico部署记录](https://www.cnblogs.com/kevingrace/p/6864804.html?utm_source=itdadao&utm_medium=referral)

[Kubernetes网络原理及方案](http://www.youruncloud.com/blog/131.html)

[容器网络那些事儿](http://www.youruncloud.com/blog/95.html)

## ingress 选型

[8款开源的Kubernetes Ingress Controller/API Gateway推荐](http://www.servicemesher.com/blog/nginx-ingress-vs-kong-vs-traefik-vs-haproxy-vs-voyager-vs-contour-vs-ambassador/)

[Kubernetes Ingress 对比](https://docs.google.com/spreadsheets/d/16bxRgpO1H_Bn-5xVZ1WrR_I-0A-GOI6egmhvqqLMOmg/edit#gid=1612037324)

[Kubernetes高可用负载均衡与集群外服务访问实践](http://www.youruncloud.com/blog/152.html)

[基于Zuul2.0搭建微服务网关以及和NGINX的测试对比](https://blog.csdn.net/zhaoenweiex/article/details/80295024)

## 存储选型

### Ceph和GFS比较，各有哪些优缺点？

说实话，这个基本没有可比性～

虽然 Sage 在最初设计 Ceph 的时候是作为一个分布式存储系统，也就是说其实 CephFS 才是最初的构想和设计(题外音)，但可以看到，后面 Ceph 俨然已经发展为一整套存储解决方案，上层能够提供对象存储(RGW)、块存储(RBD)和CephFS，可以说是一套适合各种场景，非常灵活，非常有可发挥空间的存储解决方案～

而反观 GFS ，则主要是 Google 为其大数据服务设计开发的底层文件系统，从各种资料中能够看到，其为大数据处理场景做了各种假设、定制和优化，可以说是一套专门针对大数据应用场景的，定制化程度非常高的存储解决方案。

[Ceph vs Gluster之开源存储力量的较量](https://blog.csdn.net/swingwang/article/details/77012500)

[分布式文件系统MFS、Ceph、GlusterFS、Lustre的比较](https://blog.csdn.net/weiyuefei/article/details/78270318)

## 数据库容器化选型

[MySQL到底能不能放到 Docker 里跑？同程旅游竟这么玩](https://mp.weixin.qq.com/s/d1O-UEBUxs-tsG8nMG92-w)

## 微服务架构

[微服务架构最佳实践课堂PPT- 微服务容器化的挑战和解决之道](http://www.youruncloud.com/blog/66.html)

## Kubernetes和OpenStack到底是什么关系？先搞清楚，再系列学习

Kubernetes 面向应用层，变革的是业务架构，而 OpenStack 面向资源层，改变的是资源供给模式。使用容器且集群规模不大，直接用 Kubenetes 就可以；集群规模大，不管应用是否只是跑在容器中，都是 OpenStack + Kubernetes 更好。
OpenStack + Kubernetes 是各取所长，并不只是因为惯性，而是对于多租户需求来说，Container（容器）的隔离性还需要加强，需要加一层 VM（虚拟机） 来弥补，而 OpenStack 是很好的方案。不过，VM + Container 的模式，必然有性能的损耗，所以 OpenStack 基金会也推出一个项目叫 Kata Containers，希望减少虚拟化的开销，兼顾容器的性能和隔离性。

永恒的只有变化，未来的业务都会运行在云上，容器是走向 DevOps、Cloud Native（云原生）的标准工具，已经开始走向平凡，而 Kubernetes 的编排能力，让容器能够落地到业务应用中，所以我们看到 Docker、Mesos、OpenStack 以及很多公有云、私有云服务商，都在支持 Kubernetes，大家都加入了 CNCF（云原生计算基金会）。

总结起来，OpenStack 是兼容传统的架构，而 Kubernetes 是面向未来的架构。

![image](https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1517309696705&di=2f594f3d541a02b20dcc3a48d3d3c2fd&imgtype=0&src=http%3A%2F%2Fstatic.open-open.com%2Fnews%2FuploadImg%2F20150618%2F20150618111734_7.png)

最后，计算开源云这几年发展很快，从这个问题提出到现在，社区又有了很多变化。所以要修正一个观点：Kubernetes 支持的容器运行时不仅仅是 Docker，也包括 Rkt，当然 Docker 更加流行。

简单的说，kubernetes是管理container的工具，openstack是管理VM的工具。

container可以运行在物理机上，也可以运行在VM上。所以kubernetes不是需要openstack的支持。但对于云计算来说，很多IasS都通过openstack来管理虚拟机。然后用户可以在这些虚拟机上运行docker，可以通过kubernetes进行管理。

不过kubernetes虽然是开源的，但它毕竟是为GCE服务的，Google其实并没有多少动力去支持其他平台的。

[京东从OpenStack改用Kubernetes的始末](https://tutorials.hostucan.cn/jd-openstack-kubernetes)
