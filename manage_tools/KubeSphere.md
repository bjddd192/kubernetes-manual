# KubeSphere

KubeSphere 帮助企业在云、虚拟化及物理机等任何环境中快速构建、部署和运维基于 Kubernetes 的容器架构，轻松实现微服务治理、多租户管理、DevOps 与 CI/CD、监控日志告警、应用商店、大数据、以及人工智能等业务场景。

[KubeSphere 官网](https://kubesphere.io/)

[KubeSphere 文档中心](https://kubesphere.io/docs/v2.1/zh-CN/introduction/intro/)

[kubesphere/kubesphere](https://github.com/kubesphere/kubesphere)

### 常用命令

```sh
# 安装 kuboard
wget https://kuboard.cn/install-script/kuboard.yaml
kubectl apply -f kuboard.yaml
# 查看 kuboard 运行状态
kubectl get pods -l k8s.eip.work/name=kuboard -n kube-system
# 使用 web 浏览器验证
http://10.240.114.64:32567/
# 获取管理员 token
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep kuboard-user | awk '{print $1}') 
# 获取只读用户 token
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep kuboard-viewer | awk '{print $1}') 
# 直接访问
http://10.240.114.64:32567/#/dashboard?k8sToken=eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlLXN5c3RlbSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJrdWJvYXJkLXZpZXdlci10b2tlbi1uamh0dyIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50Lm5hbWUiOiJrdWJvYXJkLXZpZXdlciIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6IjRjNDEzOWI5LTBjZjAtMTFlYS1hOGI0LWZhMTYzZTRhMzg1ZiIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDprdWJlLXN5c3RlbTprdWJvYXJkLXZpZXdlciJ9.cDomHPzz-Nu5HQrMaaaTX6Aa15c49xYXrTRTIZaPyDuTYOYlHsv4HGuwTVIw-ZsjvXtKstVlxBRJIOmXcAeq78NXoWmWspzojWkBNikW2PrHl-sQfTG8-YVsO-3vF6GWV9l5DYy0YbfQVtTVdae7Ar6SZdiRgHC3IAUMjzXsCcDOQMlFr4O0k-uyzu1phm0NoT1mRbHD4d_IO5Ox6tzAc2GHVBCx3u2jyTtKZUoBTX-DEe3S98y_Xio-HjQGGllCmbDBMPme1mbxIdgBF_VC2j19Nu2WS-NLxUUrZjEZQbNEXpuoZoBhhwUQWCEVXHAwul9shLC4HkHK8ugec8m22g

```

### 使用体会

优点：

- 安装非常简单
- 应用界面美观
- 自带验证功能，有管理员和只读用户 2种角色
- web 查看日志比较方便
- 可以 web 远程进入容器操作，非常方便
- 自带 kubernetes 教程，可以边学边用

缺点：

- 对 rc 控制器支持不好，只能操作 pod

综上考虑：可以部署到集群试用，并及时关注更新，部署方式也需要逐步升级。

### 参考资料

[为什么有了Kubernetes Dashboard，我却选Kuboard?](