# Rancher

Rancher 是一个为 DevOps 团队提供的完整的 Kubernetes 与容器管理解决方案。它解决了多 Kubernetes 集群管理、操作和安全的难题，同时为 DevOps 团队提供了运行容器化工作负载的管理工具。

[官网](https://www.rancher.cn/)

[官方文档](https://docs.rancher.cn/)

[rancher/rancher](https://github.com/rancher/rancher)

### 常用命令

```sh
# 在已有的 k8s 集群安装 rancher
docker stop rancher && docker rm -f rancher

docker run -d --name rancher -p 80:80 -p 443:443 --restart=always \
  -v /tmp/rancher_home/rancher:/var/lib/rancher \
  -v /tmp/rancher_home/auditlog:/var/log/auditlog \
  rancher/rancher:v2.0.5

# 浏览器验证：https://10.0.43.27/
# 设置管理员密码

kubectl create clusterrolebinding cluster-admin-binding --clusterrole cluster-admin --user admin
curl --insecure -sfL https://10.0.43.27/v3/import/xnhdcttkjlhs5h6sd9nh52mk2zcbxjfjs8k6x75zn4l7ngfdszjdvp.yaml | kubectl apply -f -
# 移除
# curl --insecure -sfL https://10.0.43.27/v3/import/xnhdcttkjlhs5h6sd9nh52mk2zcbxjfjs8k6x75zn4l7ngfdszjdvp.yaml | kubectl delete -f -

```

**目前发现对二进制集群有侵入影响，暂不使用！！！**

### 参考资料

[rancher 2.X 管理 已有 kubernetes 集群](https://blog.csdn.net/weixin_41806245/article/details/99459861)

[Rancher 2.1平台搭建及使用](https://www.cnblogs.com/hzw97/p/11608098.html)

[你的第一次轻量级K8S体验 —— 记一次Rancher 2.2 + K3S集成部署过程](https://yq.aliyun.com/articles/704089)

