# 常用标签

## RestartPoliy

支持三种 Pod 重启策略。

- Always：只要退出就重启
- OnFailure：失败退出（exit code 不等于0）时重启
- Never：只要退出就不再重启

注意，这里的重启是指在Pod所在Node上面本地重启，并不会调度到其他Node上去。

## ImagePullPolicy

支持三种镜像拉取策略。

- Always：不管镜像是否存在都会进行一次拉取。
- Never：不管镜像是否存在都不会进行拉取
- IfNotPresent：只有镜像不存在时，才会进行镜像拉取。

注意：

- 默认为 `IfNotPresent`，但 `:latest` 标签的镜像默认为 `Always`。
- 拉取镜像时 docker 会进行校验，如果镜像中的 MD5 码没有变，则不会拉取镜像数据。
- 生产环境中应该尽量避免使用 `:latest` 标签，而开发环境中可以借助 `:latest` 标签自动拉取最新的镜像。

## 资源限制

Kubernetes 通过 cgroups 限制容器的 CPU 和内存等计算资源，包括 requests 和 limits 等：

- spec.containers[].resources.limits.cpu：CPU上限，可以短暂超过，容器也不会被停止。
- spec.containers[].resources.limits.memory：内存上限，不可以超过；如果超过，容器可能会被停止或调度到其他资源充足的机器上。
- spec.containers[].resources.requests.cpu：CPU请求，可以超过。
- spec.containers[].resources.requests.memory：内存请求，可以超过；但如果超过，容器可能会在Node内存不足时清理。

## 健康检查

为了确保容器在部署后确实处在正常运行状态，Kubernetes 提供了两种探针，支持 exec、tcp、httpGet 方式，来探测容器的状态：

- LivenessProbe：探测应用是否处于健康状态，如果不健康则删除重建该容器。
- ReadinessProbe：探测应用是否启动完成并且处于正常服务状态，如果不正常则更新容器的状态。

## 容器生命周期钩子

容器生命周期钩子（Container Lifecycle Hooks）监听容器生命周期的特定事件，并在事件发生时执行已注册的回调函数。支持两种钩子：

- postStart： 容器启动后执行，注意由于是异步执行，它无法保证一定在ENTRYPOINT之后运行。如果失败，容器会被杀死，并根据RestartPolicy决定是否重启
- preStop：容器停止前执行，常用于资源清理。如果失败，容器同样也会被杀死

而钩子的回调函数支持两种方式：

- exec：在容器内执行命令
- httpGet：向指定URL发起GET请求

postStart和preStop钩子示例：

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: lifecycle-demo
spec:
  containers:
  - name: lifecycle-demo-container
    image: nginx
    lifecycle:
      postStart:
        exec:
          command: ["/bin/sh", "-c", "echo Hello from the postStart handler > /usr/share/message"]
      preStop:
        exec:
          command: ["/usr/sbin/nginx","-s","quit"]
```

## 指定Node

通过nodeSelector，一个Pod可以指定它所想要运行的Node节点。

首先给Node加上标签：

```sh
kubectl label nodes <your-node-name> disktype=ssd
```

接着，指定该Pod只想运行在带有 `disktype=ssd` 标签的 Node 上：

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  labels:
    env: test
spec:
  containers:
  - name: nginx
    image: nginx
    imagePullPolicy: IfNotPresent
  nodeSelector:
    disktype: ssd
```

## 限制网络带宽

可以通过给 Pod 增加 kubernetes.io/ingress-bandwidth 和 kubernetes.io/egress-bandwidth 这两个 annotation 来限制 Pod 的网络带宽。

**注意：目前只有 kubenet 网络插件支持限制网络带宽，其他CNI网络插件暂不支持这个功能。**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: qos
  annotations:
    kubernetes.io/ingress-bandwidth: 3M
    kubernetes.io/egress-bandwidth: 4M
spec:
  containers:
  - name: iperf3
    image: networkstatic/iperf3
    command:
    - iperf3
    - -s
```

## initContainers

Init Container 在所有容器运行之前执行，常用来初始化配置。

## capabilities

默认情况下，容器都是以非特权容器的方式运行。比如，不能在容器中创建虚拟网卡、配置虚拟网络。

Kubernetes 提供了修改 Capabilities 的机制，可以按需要给给容器增加或删除。比如下面的配置给容器增加了 CAP_NET_ADMIN 并删除了 CAP_KILL。

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: hello-world
spec:
  containers:
  - name: friendly-container
    image: "alpine:3.4"
    command: ["/bin/echo", "hello", "world"]
    securityContext:
      capabilities:
        add:
        - NET_ADMIN
        drop:
        - KILL
```

