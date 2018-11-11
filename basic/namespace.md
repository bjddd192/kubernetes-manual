# kubernetes Namespace

Namespace 是对一组资源和对象的抽象集合，比如可以用来将系统内部的对象划分为不同的项目组或用户组。常见的 pods, services, replication controllers和 deployments 等都是属于某一个 namespace 的（默认是 default），而 node, persistentVolumes 等则不属于任何 namespace。

Namespace 常用来隔离不同的用户，比如 Kubernetes 自带的服务一般运行在 kube-system namespace 中。

注意：

1. namespace 包含两种状态 `Active` 和 `Terminating`。在 namespace 删除过程中，namespace 状态被设置成 `Terminating`。
2. 命名空间名称满足正则表达式 `[a-z0-9]([-a-z0-9]*[a-z0-9])?`，最大长度为 63 位。
3. 删除一个 namespace 会自动删除所有属于该 namespace 的资源。
4. default 和 kube-system 命名空间不可删除。
5. 大多数 Kubernetes 资源（例如pod、services、replication controllers 或其他）都在某些 删除过程中，namespace 中。
6. 低级别资源（如 Node 和 persistentVolumes ）不在任何 namespace 中。
7. events 是一个例外，它们可能有也可能没有 namespace，具体取决于 events 的对象。
8. 可以通过 [Resource Quotas](https://kubernetes.io/docs/concepts/policy/resource-quotas/) 限制一个 namespace 所可以存取的资源。

## 管理 namespace 中的资源配额

当用多个团队或者用户共用同一个集群的时候难免会有资源竞争的情况发生，这时候就需要对不同团队或用户的资源使用配额做出限制。

```sh
# 查看 Resource Quotas
kubectl get resourcequotas -n bst-scm-petrel-dev
```

[管理namespace中的资源配额](https://jimmysong.io/kubernetes-handbook/guide/resource-quota-management.html)

## 参考资料

[kubernetes多租户分析](http://blog.decbug.com/k8s_multi_tenant/)

[Hypernetes简介——真正多租户的Kubernetes Distro](https://www.cnblogs.com/allcloud/p/7094908.html)

[hypernetes](https://github.com/hyperhq/hypernetes)

[stackube](https://github.com/openstack/stackube)
