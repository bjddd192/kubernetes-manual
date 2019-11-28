# octant

VMWare 开源了 Octant ，这是一款帮助开发人员了解应用程序在 Kubernetes 集群中如何运行的工具。它通过可视化的方式，呈现 Kubernetes 对象的依赖关系，可将本地端口请求转发到正在运行的 pod，查看 pod 日志，浏览不同的集群。

[官网](https://octant.dev/)

[官方文档](https://octant.dev/docs/master/)

[vmware-tanzu/octant](https://github.com/vmware-tanzu/octant)

### 常用命令

```sh
# 查看帮助
octant --help
# 查看版本
octant version
# 启动应用
OCTANT_LISTENER_ADDR=0.0.0.0:8900 octant
# 使用 web 浏览器验证
```

### 使用体会

优点：

- 多操作系统支持
- 整个应用符合大厂出品，比较精致（类似 harbor 风格）
- 可以方便的查看、管理集群的对象（比 dashboard 更方便）
- 可以方便地切换上下文，管理多个集群
- 可以查看日志

缺点：

- 没有权限认证体制，界面可以直接删除集群对象，不够安全
- 默认分页是 10行，且筛选功能不强，对象多了查看起来会有点不爽
- 无法批量操作
- 日志查看不是实时的，展示界面偏小

综上考虑：目前([v0.9.1](https://github.com/vmware-tanzu/octant/releases/tag/v0.9.1))只适合集群管理人员使用，期待新版本有更多的功能。

### 参考资料

[VMWare 开源 Octant，可视化的 Kubernetes 工作负载仪表板](https://cloud.tencent.com/developer/news/435706)

