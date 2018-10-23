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
