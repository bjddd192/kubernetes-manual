# kuboard

Kuboard 是一款免费的基于 Kubernetes 的微服务管理界面。

[官网](https://www.kuboard.cn/)

[官方文档](https://www.kuboard.cn/install/install-dashboard.html)

[eip-work/kuboard-press](https://github.com/eip-work/kuboard-press/)

### 常用命令

```sh
# 安装 kuboard
wget https://kuboard.cn/install-script/kuboard.yaml
kubectl apply -f kuboard.yaml
# 查看 kuboard 运行状态
kubectl get pods -l k8s.eip.work/name=kuboard -n kube-system
# 使用 web 浏览器验证
http://10.0.43.31:32567/
# 获取管理员 token
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep kuboard-user | awk '{print $1}') 
# 获取只读用户 token
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep kuboard-viewer | awk '{print $1}') 
# 直接访问
http://10.0.43.31:32567/#/dashboard?k8sToken=eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlLXN5c3RlbSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJrdWJvYXJkLXZpZXdlci10b2tlbi14YnhtaCIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50Lm5hbWUiOiJrdWJvYXJkLXZpZXdlciIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6IjUzZmE5YWE1LTBkMGQtMTFlYS05MmYyLWZhMTYzZTdmYzFiNSIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDprdWJlLXN5c3RlbTprdWJvYXJkLXZpZXdlciJ9.UxngA8WOeV6n9IvQzIr60dEi56RuQKGu8cvCms8hExvCOMv9xpueJdLT4rngMBHFore_nM751QuwZHjkNYUhm5H-4h8zOF0BY7QHxuTgBtaYbjJhseNLpNIbLi_7wg4RP7Pgveqgu30ouVoIa7_DotGXWS0hYUmuBwzj-fLG-AM9U4XZLyjvVgvMRb7ilM5ljJIs1ZqJ_cgCY-vXKe3hiLTH7GdnIcGQouwYFV-IhlKMbL2pFYRJTNbaRIlL2obqpxqcMBt4h3V6o5s6GEQL3Epe_XKj9i4SjsywIM5el-1WD0o83jjJXRA6T69w911CpTDkEOq0lTY_-VzFsdXohw

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

[为什么有了Kubernetes Dashboard，我却选Kuboard?](https://www.kubernetes.org.cn/5577.html)

