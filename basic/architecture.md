# kubernetes 体系结构

## 设计架构

Kubernetes 集群包含有节点代理 kubelet 和 Master 组件(APIs，scheduler，etc)，一切都基于分布式的存储系统。下面这张图是 Kubernetes 的架构图。

![architecture.png](/images/architecture.png)

在这张系统架构图中，我们把服务分为运行在工作节点上的服务和组成集群级别控制板的服务。

Kubernetes节点有运行应用容器必备的服务，而这些都是受 Master 的控制。

每次个节点上运行 Docker，负责所有具体的镜像下载和容器运行。

## 核心组件

- etcd：保存整个集群的状态；
- apiserver：提供资源操作的唯一入口，并提供认证、授权、访问控制、API 注册和发现等机制；
- controller manager：负责维护集群的状态，比如故障检测、自动扩展、滚动更新等；
- scheduler：负责资源的调度，按照预定的调度策略将 Pod 调度到相应的机器上；
- kubelet：负责维护容器的生命周期，同时也负责 Volume（CVI）和网络（CNI）的管理；
- Container runtime：负责镜像管理以及Pod和容器的真正运行（CRI）；
- kube-proxy：负责为 Service 提供 cluster 内部的服务发现和负载均衡；

## 附加组件

除了核心组件，还有一些推荐的 Add-ons：

- kube-dns：负责为整个集群提供 DNS 服务
- Ingress Controller：为服务提供外网入口
- Heapster：提供资源监控
- Dashboard：提供 GUI
- Federation：提供跨可用区的集群
- Fluentd-elasticsearch：提供集群日志采集、存储与查询
