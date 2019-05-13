# 简介

Kubernetes 是一个开源的，用于管理多个主机上的容器化的应用，Kubernetes 的目标是让部署容器化的应用简单并且高效，Kubernetes 提供了应用部署、规划、更新、维护的一种机制。

Kubernetes 一个核心的特点就是能够自主的管理容器来保证平台中的容器按照用户的期望状态运行。

在 Kubenetes中，所有的容器均在 Pod 中运行，一个 Pod 可以承载一个或者多个相关的容器，同一个 Pod 中的容器会部署在同一个物理机器上并且能够共享资源。一个 Pod 也可以包含 O 个或者多个磁盘卷组（volumes），这些卷组将会以目录的形式提供给一个容器，或者被所有 Pod 中的容器共享。

Kubernetes 提供了服务的抽象，并提供了固定的 IP 地址和 DNS 名称，而这些与一系列 Pod 进行动态关联，所以我们可以关联任何我们想关联的Pod，当一个 Pod 中的容器访问这个地址的时候，这个请求会被转发到本地代理（kube proxy），每台机器上均有一个本地代理，然后被转发到相应的后端容器。Kubernetes 通过一种轮询机制选择相应的后端容器，这些动态的Pod被替换的时候，Kube proxy 时刻追踪着，所以，服务的 IP地址（dns名称），从来不变。

## 起源

在 Docker 作为高级容器引擎快速发展的同时，Google 也开始将自身在容器技术及集群方面的积累贡献出来。在 Google 内部，容器技术已经应用了很多年，Borg 系统运行管理着成千上万的容器应用，在它的支持下，无论是谷歌搜索、Gmail 还是谷歌地图，可以轻而易举地从庞大的数据中心中获取技术资源来支撑服务运行。

Borg 是集群的管理器，在它的系统中，运行着众多集群，而每个集群可由成千上万的服务器联接组成，Borg 每时每刻都在处理来自众多应用程序所提交的成百上千的 Job，对这些 Job 进行接收、调度、启动、停止、重启和监控。正如 Borg 论文中所说，Borg 提供了 3 大好处：

1. 隐藏资源管理和错误处理，用户仅需要关注应用的开发。
2. 服务高可用、高可靠。
3. 可将负载运行在由成千上万的机器联合而成的集群中。

作为 Google 的竞争技术优势，Borg 理所当然的被视为商业秘密隐藏起来，但当 Tiwtter 的工程师精心打造出属于自己的 Borg 系统（Mesos）时，Google 也审时度势地推出了来源于自身技术理论的新的开源工具。

2014 年 6 月，谷歌云计算专家埃里克·布鲁尔（Eric Brewer）在旧金山的发布会为这款新的开源工具揭牌，它的名字 Kubernetes 在希腊语中意思是船长或领航员，这也恰好与它在容器集群管理中的作用吻合，即作为装载了集装箱（Container）的众多货船的指挥者，负担着全局调度和运行监控的职责。

虽然 Google 推出 Kubernetes 的目的之一是推广其周边的计算引擎（Google Compute Engine）和谷歌应用引擎（Google App Engine）。但 Kubernetes 的出现能让更多的互联网企业可以享受到连接众多计算机成为集群资源池的好处。

Kubernetes 对计算资源进行了更高层次的抽象，通过将容器进行细致的组合，将最终的应用服务交给用户。Kubernetes 在模型建立之初就考虑了容器跨机连接的要求，支持多种网络解决方案，同时在 Service 层次构建集群范围的 SDN 网络。其目的是将服务发现和负载均衡放置到容器可达的范围，这种透明的方式便利了各个服务间的通信，并为微服务架构的实践提供了平台基础。而在 Pod 层次上，作为 Kubernetes 可操作的最小对象，其特征更是对微服务架构的原生支持。

Kubernetes 项目来源于 Borg，可以说是集结了 Borg 设计思想的精华，并且吸收了 Borg 系统中的经验和教训。

Kubernetes 作为容器集群管理工具，于 2015 年 7 月 22 日迭代到 v1.0 并正式对外公布，这意味着这个开源容器编排系统可以正式在生产环境使用。与此同时，谷歌联合 Linux 基金会及其他合作伙伴共同成立了 CNCF 基金会(Cloud Native Computing Foundation)，并将 Kuberentes 作为首个编入 CNCF 管理体系的开源项目，助力容器技术生态的发展进步。Kubernetes 项目凝结了 Google 过去十年间在生产环境的经验和教训，从 Borg 的多任务分配资源块到 Kubernetes 的多副本 Pod，从 Borg 的 Cell 集群管理，到 Kubernetes 设计理念中的联邦集群，在 Docker 等高级引擎带动容器技术兴起和大众化的同时，为容器集群管理提供独了到见解和新思路。

## 待阅资料

[kubernetes认证授权机制](https://www.jianshu.com/p/bb973ab1029b)

## 参考资料

[服务网格实践手册](https://jimmysong.io/istio-handbook/)

[Kubernetes Handbook——Kubernetes中文指南/云原生应用架构实践手册](https://jimmysong.io/kubernetes-handbook/)

[生产级别的容器编排系统](https://k8smeetup.github.io/)

[Kubernetes 中如何保证优雅地停止 Pod](https://www.jianshu.com/p/ec379fe9c58c)

[K8S 最佳实践：正常终止](https://yq.aliyun.com/articles/679296)

[Kubernetes 中如何保证优雅地停止 Pod](https://www.jianshu.com/p/ec379fe9c58c)
