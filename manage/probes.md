# probes

配置探针(Probe)相关属性
探针(Probe)有许多可选字段，可以用来更加精确的控制Liveness和Readiness两种探针的行为(Probe)：

initialDelaySeconds：Pod启动后延迟多久才进行检查，单位：秒。
periodSeconds：检查的间隔时间，默认为10，单位：秒。
timeoutSeconds：探测的超时时间，默认为1，单位：秒。
successThreshold：探测失败后认为成功的最小连接成功次数，默认为1，在Liveness探针中必须为1，最小值为1。
failureThreshold：探测失败的重试次数，重试一定次数后将认为失败，在readiness探针中，Pod会被标记为未就绪，默认为3，最小值为1。

什么时候用readiness 什么时候用readiness
比如如果一个http 服务你想一旦它访问有问题我就想重启容器。那你就定义个liveness 检测手段是http get。反之如果有问题我不想让它重启，只是想把它除名不要让请求到它这里来。就配置readiness。

注意，liveness不会重启pod，pod是否会重启由你的restart policy 控制。

[k8s健康检查详解](https://www.jianshu.com/p/16a375199cf2)

[k8s之Pod健康检测](http://blog.51cto.com/newfly/2137136)

[Kubernetes健康检查如何做？官方推荐教程](http://www.sohu.com/a/232433529_268033)

[Pod Lifecycle](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/)