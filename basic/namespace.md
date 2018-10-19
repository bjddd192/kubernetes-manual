# kubernetes Namespace

Namespace 是对一组资源和对象的抽象集合，比如可以用来将系统内部的对象划分为不同的项目组或用户组。常见的 pods, services, replication controllers和 deployments 等都是属于某一个 namespace 的（默认是 default），而 node, persistentVolumes 等则不属于任何 namespace。

Namespace 常用来隔离不同的用户，比如 Kubernetes 自带的服务一般运行在 kube-system namespace 中。

注意：

1. namespace 包含两种状态 `Active` 和 `Terminating`。在 namespace 删除过程中，namespace 状态被设置成 `Terminating`。
2. 命名空间名称满足正则表达式 `[a-z0-9]([-a-z0-9]*[a-z0-9])?`，最大长度为 63 位。
3. 删除一个 namespace 会自动删除所有属于该 namespace 的资源。
4. default 和 kube-system 命名空间不可删除。



