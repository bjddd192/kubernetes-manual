# Service

服务发现

### 通过环境变量发现服务

### 通过DNS发现服务

### 通过FQDN发现服务

```sh
kubectl -n belle-petrel-uat exec -it oms-web-57f8cdfc95-c8sd8 bash
# 以下请求效果一样
wget http://oms-web
wget http://oms-web.belle-petrel-uat
wget http://oms-web.belle-petrel-uat.svc.cluster.local
```
