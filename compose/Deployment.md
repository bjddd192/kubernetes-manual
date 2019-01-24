# Deployment

Deployment 为 Pod 和 ReplicaSet 提供了一个声明式定义(declarative)方法，用来替代以前的 ReplicationController 来方便的管理应用。典型的应用场景包括：

- 定义 Deployment 来创建 Pod 和 ReplicaSet
- 滚动升级和回滚应用
- 扩容和缩容
- 暂停和继续 Deployment

比如一个简单的nginx应用可以定义为：

```yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 3
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.7.9
        ports:
        - containerPort: 80
```

扩容：

```sh
kubectl scale deployment nginx-deployment --replicas 10
```

如果集群支持 horizontal pod autoscaling 的话，还可以为 Deployment 设置自动扩展：

```sh
kubectl autoscale deployment nginx-deployment --min=10 --max=15 --cpu-percent=80
```

更新镜像也比较简单：

```sh
kubectl set image deployment/nginx-deployment nginx=nginx:1.9.1
```

回滚：

```sh
kubectl rollout undo deployment/nginx-deployment
```

## Deployment 实战

### yaml 文件

service.yaml 

```yaml
apiVersion: v1
kind: Service
metadata:
  name: leo-nginx
  namespace: dev-web
  labels:
    app.kubernetes.io/name: nginx
    app.kubernetes.io/instance: leo-nginx
    app.kubernetes.io/managed-by: Tiller
    helm.sh/chart: nginx-v1.10.1
spec:
  type: NodePort
  ports:
  -
    name: container-port
    nodePort: 22800
    port: 80
  -
    name: container-2port
    nodePort: 20802
    port: 30802
  selector:
    app.kubernetes.io/name: nginx
    app.kubernetes.io/instance: leo-nginx
```

deployment.yaml 

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  # 使用 include 引用模版允许我们使用管道和函数
  name: leo-nginx
  namespace: dev-web
  labels:
    app.kubernetes.io/name: nginx
    app.kubernetes.io/instance: leo-nginx
    app.kubernetes.io/version: "1.10"
    app.kubernetes.io/managed-by: Tiller
    helm.sh/chart: nginx-v1.10.1
  annotations:
    kubernetes.io/change-cause: "升级测试哦"
spec:
  replicas: 2
  selector:
    matchLabels:
      app.kubernetes.io/name: nginx
      app.kubernetes.io/instance: leo-nginx
      app.kubernetes.io/version: "1.10"
  template:
    metadata:
      labels:
        app.kubernetes.io/name: nginx
        app.kubernetes.io/instance: leo-nginx
        app.kubernetes.io/version: "1.10"
    spec:
      nodeSelector:
        beta.kubernetes.io/arch: amd64
        beta.kubernetes.io/os: linux
        kubernetes.io/hostname: 172.20.32.5

      containers:
        - name: nginx
          image: "nginx:1.10"
          imagePullPolicy: Always
          ports:
            - name: http
              containerPort: 80
              protocol: TCP
          livenessProbe:
            httpGet:
              path: /
              port: http
          readinessProbe:
            httpGet:
              path: /
              port: http
          resources:
            {}
```

### 部署操作

```sh
# 查看历史版本(CHANGE-CAUSE为NONE的原因参考：https://cloud.tencent.com/developer/article/1347201)
kubectl rollout history deployment leo-nginx -n dev-web
# 或者
kubectl rollout history deployment leo-nginx --revision=3 -n dev-web

# 查看部署详细信息
kubectl describe deployment leo-nginx -n dev-web   

# 升级版本(默认为滚动升级)
kubectl set image deployment leo-nginx nginx=nginx:1.12 -n dev-web
# 或者
kubectl edit deployment leo-nginx -n dev-web
# 或者 使用yaml文件升级
kubectl apply -f deployment.yaml

# 查看部署状态
kubectl rollout status deployment leo-nginx -n dev-web
# 或者
kubectl get deployment leo-nginx -n dev-web 
# 或者 注意：更新前后的 RS 都会保留下来
kubectl get rs -n dev-web | grep leo-nginx

# 暂停升级
kubectl rollout pause deployment leo-nginx -n dev-web

# 恢复升级
kubectl rollout resume deployment leo-nginx -n dev-web

# 回滚到上一版本
kubectl rollout undo deployment leo-nginx -n dev-web

# 回滚到指定版本
kubectl rollout undo deployment leo-nginx --to-revision=1 -n dev-web
```

## 参考资料

[Deployment vs ReplicationController in Kubernetes](https://cloud.tencent.com/developer/article/1004521)

[Kubernetes的Deployment与ReplicaSet了解与基础操作](https://cloud.tencent.com/developer/article/1347201)

[使用kubernetes的deployment进行RollingUpdate](https://www.jianshu.com/p/6bc8e0ae65d1)


