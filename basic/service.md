# kubernetes Service

Kubernetes Pod 是平凡的，它们会被创建，也会死掉，并且他们是不可复活的。 Replication Controllers 动态的创建和销毁 Pods(比如规模扩大或者缩小，或者执行动态更新)。每个 pod 都有自己的 IP，这些 IP 也随着时间的变化也不能持续依赖。这样就引发了一个问题：如果一些 Pods（让我们叫它作后台）提供了一些功能供其它的 Pod 使用（让我们叫作前台），在 kubernete 集群中是如何实现让这些前台能够持续的追踪到这些后台的？

**答案是：Service**

Kubernete Service 是一个定义了一组 Pod 的策略的抽象，我们也有时候叫做宏观服务。这些被服务标记的Pod都是通过 label Selector 决定的。

对于 Kubernete 原生的应用，Kubernete 提供了一个简单的 Endpoints API，这个 Endpoints api 的作用就是当一个服务中的 Pod 发生变化时，Endpoints API 随之变化，对于那些不是原生的程序，Kubernetes 提供了一个基于虚拟 IP 的网桥的服务，这个服务会将请求转发到对应的后台Pod。

每一个节点上都运行了一个 kube-proxy，这个应用监控着 Kubermaster 增加和删除服务，对于服务，kube-proxy 会随机开启一个本机端口，任何发向这个端口的请求都会被转发到一个后台的 Pod 当中，而如何选择是哪一个后台的 Pod 的是基于 SessionAffinity 进行的分配。kube-proxy 会增加 iptables rules 来实现捕捉这个服务的 IP 和端口来并重定向到前面提到的端口。最终的结果就是所有的对于这个服务的请求都会被转发到后台的Pod中。

## Service 特性

- 支持 TCP 和 UDP，但是默认的是 TCP。
- 可以将一个`入端口`转发到任何`目标端口`。
- 默认情况下 targetPort 的值会和 port 的值相同。

## 没有选择器的服务

适用场景：

1. 有一个额外的数据库云在生产环境中，但是在测试的时候，希望使用自己的数据库
2. 希望将服务指向其它的服务或者其它命名空间或者其它的云平台上的服务
3. 正在向 kubernete 迁移，并且后台并没有在 Kubernete 中

```sh
{
  “kind”: “Service”,
  “apiVersion”: “v1″,
  “metadata”: {
    “name”: “my-service”
  },
  “spec”: {
    “ports”: [
      {
        “protocol”: “TCP”,
        “port”: 80,
        “targetPort”: 9376
      }
    ]
  }
}
```

```sh
{
  “kind”: “Endpoints”,
  “apiVersion”: “v1″,
  “metadata”: {
    “name”: “my-service”
  },
  “subsets”: [
    {
      “addresses”: [
        {
          “IP”: “1.2.3.4”
        }
      ],
      “ports”: [
        {
          “port”: 80
        }
      ]
    }
  ]
}
```

这样的话，这个服务虽然没有 selector，但是却可以正常工作，所有的请求都会被转发到 1.2.3.4：80

## Multi-Port Services（多端口服务）

可能很多服务需要开发不止一个端口,为了满足这样的情况，Kubernetes 允许在定义时候指定多个端口，当我们使用多个端口的时候，我们需要指定所有端口的名称，这样 endpoints 才能清楚。

## 选择自己的 IP 地址

可以在创建服务的时候指定 IP 地址，将 spec.clusterIP 的值设定为我们想要的IP地址即可。选择的 IP 地址必须是一个有效的 IP 地址，并且要在 API server 分配的 IP 范围内，如果这个 IP 地址是不可用的，apiserver 会返回 422http 错误代码来告知是 IP 地址不可用。

## 服务发现

Kubernetes 支持两种方式的来发现服务 ，环境变量和 DNS。

### 环境变量

当一个Pod在一个node上运行时，kubelet 会针对运行的服务增加一系列的环境变量，它支持Docker links compatible 和普通环境变量

例如：

redis-master 服务暴露了 TCP 6379 端口，并且被分配了 10.0.0.11 IP 地址

那么我们就会有如下的环境变量

```sh
REDIS_MASTER_SERVICE_HOST=10.0.0.11
REDIS_MASTER_SERVICE_PORT=6379
REDIS_MASTER_PORT=tcp://10.0.0.11:6379
REDIS_MASTER_PORT_6379_TCP=tcp://10.0.0.11:6379
REDIS_MASTER_PORT_6379_TCP_PROTO=tcp
REDIS_MASTER_PORT_6379_TCP_PORT=6379
REDIS_MASTER_PORT_6379_TCP_ADDR=10.0.0.11
```

使用环境变量对系统有一个要求：所有的想要被POD访问的服务，必须在POD创建之前创建，否则这个环境变量不会被填充，使用 DNS 则没有这个问题

### DNS
