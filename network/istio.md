# istio

[官方网站](https://istio.io/)

[官方文档](https://istio.io/latest/docs/)

[免费练习平台网站](https://katacoda.com/)

[Istio 学习笔记](https://imroc.cc/istio/)

### 安装部署

[getting-started](https://istio.io/latest/docs/setup/getting-started/)

[安装Istio](https://cloud.tencent.com/developer/article/1774756)

```sh
# 在线安装(需要代理)
curl -L https://istio.io/downloadIstio | sh -
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.6.8 TARGET_ARCH=x86_64 sh -

# 离线安装
cd /tmp
wget http://10.0.43.24:8066/package/istio/istio-1.11.4-linux-amd64.tar.gz
tar zxvf istio-1.11.4-linux-amd64.tar.gz -C /usr/local/
echo 'export ISTIO_HOME=/usr/local/istio-1.11.4' >> /etc/profile
echo 'export PATH=$PATH:$ISTIO_HOME/bin' >> /etc/profile
source /etc/profile
istioctl version
cd /usr/local/istio-1.11.4/

# 注意：阿里云会产生负载均衡器
kubectl get svc istio-ingressgateway -n istio-system

# 安装实验环境
istioctl install --set profile=demo -y

# 验证环境
kubectl -n istio-system get all
kubectl -n istio-system get crd
kubectl api-resources | grep istio

# 添加命名空间标签以指示 Istio 在稍后部署应用程序时自动注入 Envoy sidecar 代理
kubectl label namespace default istio-injection=enabled
kubectl get namespace -L istio-injection
kubectl get namespace --show-labels

# 部署示例程序
cd /usr/local/istio-1.11.4/
kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml
kubectl get all
# 通过检查响应中的页面标题来查看应用程序是否在集群内运行
kubectl exec "$(kubectl get pod -l app=ratings -o jsonpath='{.items[0].metadata.name}')" -c ratings -- curl -sS productpage:9080/productpage | grep -o "<title>.*</title>"
# 此应用程序与 Istio 网关关联
kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml
# 检查istio配置
istioctl analyze
# 确定入口 IP 和端口
kubectl get svc istio-ingressgateway -n istio-system
# 查看服务nodeport
# kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}'
# kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}'
# 浏览器验证外部访问：http://120.79.180.244/productpage

# 部署遥测插件
kubectl apply -f samples/addons
kubectl rollout status deployment/kiali -n istio-system
kubectl get all -n istio-system
```

### 练习

#### 13 | 动态路由：用Virtual Service和Destination Rule设置路由规则

```sh
# 将所有流量打向v1版本
cd /usr/local/istio-1.11.4/
kubectl apply -f samples/bookinfo/networking/virtual-service-all-v1.yaml
kubectl apply -f samples/bookinfo/networking/destination-rule-all.yaml
# VS里的hosts指向的就是DR的host；DR的host设置的是底层平台（如k8s）的service名称，因为最终是需要利用平台的dns来把请求导向目的地的。
# 这种用2个api资源设计的目的之一就是各司其职，VS负责配置路由信息，DR负责配置目标和策略。

# 加上 regex match 将有 end-user header 的 request到 rule v2
tee samples/bookinfo/networking/virtual-service-loginuser-to-v2.yaml <<-'EOF'
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: reviews
spec:
  hosts:
  - reviews
  http:
  - match:
    - headers:
        end-user:
          regex: .*
    route:
    - destination:
        host: reviews
        subset: v2
  - route:
    - destination:
        host: reviews
        subset: v1
EOF
kubectl apply -f samples/bookinfo/networking/virtual-service-loginuser-to-v2.yaml
```

#### 14 | 网关：用Gateway管理进入网格的流量

```sh
kubectl get gw
kubectl create -f - <<EOF
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: test-gateway
spec:
  selector:
    istio: ingressgateway
  servers:
  - hosts:
    - '*'
    port:
      name: http
      number: 80
      protocol: HTTP
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: test-gateway
spec:
  hosts:
  - '*'
  gateways:
  - test-gateway
  http:
  - match:
    - uri:
        prefix: /details
    - uri:
        exact: /health
    route:
    - destination:
        host: details
        port:
          number: 9080
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: test-gateway
spec:
  hosts:
  - '*'
  gateways:
  - test-gateway
  http:
  - match:
    - uri:
        prefix: /details
    - uri:
        exact: /health
    route:
    - destination:
        host: details
        port:
          number: 9080
EOF
curl -H "Host: abc.k8s.com" http://120.79.180.244/health
curl -H "Host: abc.k8s.com" http://120.79.180.244/details/0
```

#### 15 | 服务入口：用Service Entry扩展你的网格服务

```sh
kubectl apply -f samples/sleep/sleep.yaml
# 外部测试网站：http://httpbin.org ，http://httpbin.org/headers 这个可以返回头信息
# 可以正常访问
kubectl exec -it sleep-557747455f-r6zk4 -c sleep -- curl http://httpbin.org/headers
# 关闭出流量可访问权限 
# kubectl get configmap istio -n istio-system -o yaml | sed 's/mode: ALLOW_ANY/mode: ALLOW_ANYREGISTRY_ONLY/g' | kubectl replace -n istio-system -f -
# 1.6以上版本此命令不可用，需要 kubectl edit configmap istio -n istio-system
# 手动添加（放置在 trustDomain: cluster.local 下面）：
#    outboundTrafficPolicy:
#      mode: REGISTRY_ONLY
# 关闭后再次执行 kubectl exec -it sleep-557747455f-r6zk4 -c sleep -- curl http://httpbin.org/headers 发现无法访问了
# 为外部服务 httpbin 配置 ServiceEntry
kubectl create -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: ServiceEntry
metadata:
  name: httpbin-ext
spec:
  hosts:
  - httpbin.org
  ports:
  - number: 80
    name: http
    protocol: HTTP
  location: MESH_EXTERNAL
  resolution: DNS
EOF
kubectl get se
# 再次执行 kubectl exec -it sleep-557747455f-r6zk4 -c sleep -- curl http://httpbin.org/headers 发现可以访问了

# 简单来说：
# 1. 如果resolution配的是DNS，没有配置endpoint，它会配合hosts字段进行解析；
# 2. 如果设置了endpoint为具体IP，resolution就要设置为STATIC，表示直接使用IP，不用解析；
# 3. 如果resolution配的是DNS，也配置了endpoint，会解析endpoint里设置的地址；
# 4. address这个字段是关联服务的VIP地址，对HTTP是不生效的。
# 可以再仔细琢磨下这个示例：
apiVersion: networking.istio.io/v1alpha3
kind: ServiceEntry
metadata:
  name: external-svc-mongocluster
spec:
  hosts:
  - mymongodb.somedomain # not used
  addresses:
  - 192.192.192.192/24 # VIPs
  ports:
  - number: 27018
    name: mongodb
    protocol: MONGO
  location: MESH_INTERNAL
  resolution: STATIC
  endpoints:
  - address: 2.2.2.2
  - address: 3.3.3.3
```

#### 16 | 流量转移：灰度发布是如何实现的？

```sh
kubectl apply -f samples/bookinfo/networking/virtual-service-reviews-50-v3.yaml
# 作业：根据 user-agent 进行路由
kubectl apply -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: reviews
spec:
  hosts:
  - reviews
  http:
  - match:
    - headers:
        user-agent:
          regex: '.*Chrome.*'
    route:
    - destination:
        host: reviews
        subset: v2
  - route:
    - destination:
        host: reviews
        subset: v1
EOF
```

#### 17 | Ingress：控制进入网格的请求

```sh
kubectl apply -f samples/httpbin/httpbin.yaml
kubectl create -f - <<EOF
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: httpbin-gateway
spec:
  selector:
    istio: ingressgateway
  servers:
  - hosts:
    - 'httpbin.example.com'
    port:
      name: http
      number: 80
      protocol: HTTP
EOF

kubectl apply -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: httpbin
spec:
  hosts:
  - 'httpbin.example.com'
  gateways:
  - httpbin-gateway
  http:
  - match:
    - uri:
        prefix: /status
    - uri:
        prefix: /delay
    route:
    - destination:
        host: httpbin
        port:
          number: 8000
EOF
# 测试
curl -I -H "Host: httpbin.example.com" http://120.79.180.244/status/200
curl -I -H "Host: httpbin.example.com" http://120.79.180.244/delay/2
```

#### 18 | Egress：用Egress实现访问外部服务

```sh
kubectl create -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: ServiceEntry
metadata:
  name: httpbin
spec:
  hosts:
  - httpbin.org
  ports:
  - number: 80
    name: http-port
    protocol: HTTP
  resolution: DNS
EOF

kubectl -n istio-system get pod
kubectl -n istio-system logs -f --tail 50 istio-egressgateway-5f8b47cfc-npwp5
kubectl exec -it sleep-557747455f-r6zk4 -c sleep -- curl http://httpbin.org/ip

kubectl create -f - <<EOF
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: istio-egressgateway
spec:
  selector:
    istio: egressgateway
  servers:
  - hosts:
    - 'httpbin.org'
    port:
      name: http
      number: 80
      protocol: HTTP
EOF

kubectl create -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: vs-for-egressgateway
spec:
  hosts:
  - httpbin.org
  gateways:
  - istio-egressgateway
  - mesh
  http:
  - match:
    - gateways:
      - mesh
      port: 80
    route:
    - destination:
        host: istio-egressgateway.istio-system.svc.cluster.local
        subset: httpbin
        port:
          number: 80
      weight: 100
  - match:
    - gateways:
      - istio-egressgateway
      port: 80
    route:
    - destination:
        host: httpbin.org
        port:
          number: 80
      weight: 100
---
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: dr-for-egressgateway
spec:
  host: istio-egressgateway.istio-system.svc.cluster.local
  subsets:
  - name: httpbin
EOF

kubectl -n istio-system logs -f --tail 50 istio-egressgateway-5f8b47cfc-npwp5
kubectl exec -it sleep-557747455f-r6zk4 -c sleep -- curl http://httpbin.org/ip
# 再次执行，发现发生了2跳，第一跳流量进入egress，第二跳到目标公网地址
```

#### 19 | 超时重试：提升系统的健壮性和可用性

```sh
kubectl apply -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: reviews
spec:
  hosts:
  - reviews
  http:
  - route:
    - destination:
        host: reviews
        subset: v2
EOF

# 给 ratings 服务增加一个故障注入，延迟2s
kubectl apply -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: ratings
spec:
  hosts:
  - ratings
  http:
  - fault:
      delay:
        percent: 100
        fixedDelay: 2s
    route:
    - destination:
        host: reviews
        subset: v1
EOF

# 给 reviews 服务增加一个超时设置
kubectl apply -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: reviews
spec:
  hosts:
  - reviews
  http:
  - route:
    - destination:
        host: reviews
        subset: v2
    timeout: 1s
EOF

# 取消超时设置
kubectl apply -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: reviews
spec:
  hosts:
  - reviews
  http:
  - route:
    - destination:
        host: reviews
        subset: v2
EOF

# 给 ratings 服务增加一个超时重试机制，设置5s故障超时，重试2次
kubectl apply -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: ratings
spec:
  hosts:
  - ratings
  http:
  - fault:
      delay:
        percent: 100
        fixedDelay: 5s
    route:
    - destination:
        host: reviews
        subset: v1
    retries:
      attempts: 2
      perTryTimeout: 1s
EOF

# 刷新浏览器，查看envoy日志
kubectl logs -f  ratings-v1-b6994bb9-5qlcr -c istio-proxy 
```

#### 20 | 熔断：“秒杀”场景下的过载保护是如何实现的？

```sh
kubectl apply -f samples/httpbin/httpbin.yaml

# 熔断配置
kubectl create -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: httpbin
spec:
  host: httpbin
  trafficPolicy:
    connectionPool:
      tcp:
        maxConnections: 1
      http:
        http1MaxPendingRequests: 1
        maxRequestsPerConnection: 1
    outlierDetection:
      consecutiveErrors: 1
      interval: 1s
      baseEjectionTime: 3m
      maxEjectionPercent: 100
EOF

# 安装 fortio 压测工具
kubectl apply -f samples/httpbin/sample-client/fortio-deploy.yaml

fortio_pod=$(kubectl get pod | grep fortio | awk '{ print $1 }')
kubectl exec -it $fortio_pod -c fortio -- /usr/bin/fortio load -curl http://httpbin:8000/get
# 开始压测
kubectl exec -it $fortio_pod -c fortio -- /usr/bin/fortio load -c 2 -qps 0 -n 20 -loglevel Warning http://httpbin:8000/get
# 查看 overflow 指标，就是被熔断的请求次数
kubectl exec $fortio_pod -c istio-proxy -- pilot-agent request GET stats | grep httpbin.default | grep pending
```

#### 21 | 故障注入：在Istio中实现一个“Chaos Monkey”

```sh
# 恢复所有的路由信息
kubectl apply -f samples/bookinfo/networking/virtual-service-all-v1.yaml
# 使用reviews的v2版本
kubectl apply -f samples/bookinfo/networking/virtual-service-reviews-test-v2.yaml
# 可以看到规则：使用 jason 用户登录可以使用v2版本
kubectl describe vs reviews
# 配置延迟
kubectl apply -f samples/bookinfo/networking/virtual-service-ratings-test-delay.yaml
# 查看配置
cat samples/bookinfo/networking/virtual-service-ratings-test-delay.yaml
```

#### 22 | 流量镜像：解决线上问题排查的难题

```sh
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: httpbin-v2
spec:
  replicas: 1
  selector:
    matchLabels:
      app: httpbin
      version: v2
  template:
    metadata:
      labels:
        app: httpbin
        version: v2
    spec:
      containers:
      - image: docker.io/kennethreitz/httpbin
        imagePullPolicy: IfNotPresent
        name: httpbin
        ports:
        - containerPort: 80
        command: ["gunicorn", "--access-logfile", "-", "-b", "0.0.0.0:80", "httpbin:app"]
EOF

kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: httpbin-v3
spec:
  replicas: 1
  selector:
    matchLabels:
      app: httpbin
      version: v3
  template:
    metadata:
      labels:
        app: httpbin
        version: v3
    spec:
      containers:
      - image: docker.io/kennethreitz/httpbin
        imagePullPolicy: IfNotPresent
        name: httpbin
        ports:
        - containerPort: 80
        command: ["gunicorn", "--access-logfile", "-", "-b", "0.0.0.0:80", "httpbin:app"]
EOF

kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: httpbin
  labels:
    app: httpbin
    service: httpbin
spec:
  ports:
  - name: http
    port: 8000
    targetPort: 80
  selector:
    app: httpbin
EOF

kubectl apply -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: httpbin
spec:
  hosts:
  - httpbin
  http:
  - route:
    - destination:
        host: httpbin
        subset: v2
      weight: 100
---
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: httpbin
spec:
  host: httpbin
  subsets:
  - name: v2
    labels:
      version: v2
  - name: v3
    labels:
      version: v3
EOF

# 验证服务
sleep_pod=$(kubectl get pod | grep sleep | awk '{ print $1 }')
kubectl exec -it $sleep_pod -c sleep -- sh -c 'curl http://httpbin:8000/headers'

# 配置镜像
kubectl apply -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: httpbin
spec:
  hosts:
  - httpbin
  http:
  - route:
    - destination:
        host: httpbin
        subset: v2
      weight: 100
    mirror:
      host: httpbin
      subset: v3
    mirrorPercentage:
      value: 100
EOF

# 再次触发，并查看日志，发现v2、v3版本都产生了请求日志
kubectl exec -it $sleep_pod -c sleep -- sh -c 'curl http://httpbin:8000/headers'
```
#### 23 | 洞察你的服务：使用Kiali观测你的微服务应用

#### 24 | 指标：使用Prometheus收集指标

webassembly架构

#### 25 | 监控：使用Grafana查看系统的整体状态

#### 26 | 日志：如何获取Envoy的日志并进行调试

```sh
# 确认 envoy 日志配置是否开启，如果值是 /dev/stdout 表示开启，如果是设置为空，则表示关闭。
kubectl -n istio-system get cm istio -o=yaml | grep accessLogFile

# 修改日志格式为 json
kubectl -n istio-system edit cm istio
# accessLogEncoding: 'JSON'

kubectl logs -f --tail 20 productpage-v1-6b746f74dc-2ksq6 -c istio-proxy
```

envoy 流量五元组：

- downstream_remote_address
- downstream_local_address
- upstream_local_address
- upstream_host
- upstream_cluster

调试关键字段：response_flags

- UH：表示 upstream cluster 中没有健康的 host，503
- UF：表示 upstream 连接失败，据此可以判断出流量断点位置，503
- UO：表示 upstream overflow (熔断)
- NR：表示找不到路由，404
- URX：请求被拒绝因为限流或最大连接次数

#### 27 | 分布式追踪：使用Jeager对应用进行分布式追踪

span、span context、trace

```sh
# 确认 jaeger 安装
kubectl -n istio-system get deployment jaeger
kubectl -n istio-system get svc tracing
```

#### 28 | 守卫网格：配置TLS安全网关

SDS：安全发现服务

```sh
# 查看 curl 是不是 LibreSSL 编译的(mac)
curl --version | grep LibreSSL

cd /usr/local/istio-1.11.4/

# 为服务创建根证书和私钥：
openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -subj '/O=example Inc./CN=example.com' -keyout example.com.key -out example.com.crt

# 为httpbin.example.com创建证书和私钥：
openssl req -out httpbin.example.com.csr -newkey rsa:2048 -nodes -keyout httpbin.example.com.key -subj "/CN=httpbin.example.com/O=httpbin organization"
openssl x509 -req -days 365 -CA example.com.crt -CAkey example.com.key -set_serial 0 -in httpbin.example.com.csr -out httpbin.example.com.crt

# 创建secret
kubectl create -n istio-system secret tls httpbin-credential --key=httpbin.example.com.key --cert=httpbin.example.com.crt

kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: httpbin
  labels:
    app: httpbin
spec:
  ports:
  - name: http
    port: 8000
  selector:
    app: httpbin
EOF

kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: httpbin
spec:
  replicas: 1
  selector:
    matchLabels:
      app: httpbin
      version: v1
  template:
    metadata:
      labels:
        app: httpbin
        version: v1
    spec:
      containers:
      - image: docker.io/citizenstig/httpbin
        imagePullPolicy: IfNotPresent
        name: httpbin
        ports:
        - containerPort: 8000
EOF

# 创建证书 secret
kubectl create -n istio-system secret tls httpbin-credential --key=httpbin.example.com.key --cert=httpbin.example.com.crt

kubectl apply -f - <<EOF
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: httpbin-gateway
spec:
  selector:
    istio: ingressgateway
  servers:
  - hosts:
    - 'httpbin.example.com'
    tls:
      mode: SIMPLE
      credentialName: httpbin-credential
    port:
      name: https
      number: 443
      protocol: HTTPS
EOF

kubectl apply -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: httpbin
spec:
  hosts:
  - 'httpbin.example.com'
  gateways:
  - httpbin-gateway
  http:
  - match:
    - uri:
        prefix: /status
    - uri:
        prefix: /delay
    route:
    - destination:
        host: httpbin
        port:
          number: 8000
EOF

# 请求验证，会出现一个小茶壶的图片
curl -v -HHost:httpbin.example.com \
--resolve httpbin.example.com:443:120.79.180.244 \
--cacert example.com.crt "https://httpbin.example.com:443/status/418"

# 如不加证书，则会拒绝访问
curl -v -HHost:httpbin.example.com \
--resolve httpbin.example.com:443:120.79.180.244 \
"https://httpbin.example.com:443/status/418"
```

#### 29 | 双重保障：为应用设置不同级别的双向TLS

对等认证，对网络要求比较高，只适合服务之间的认证。

```sh
kubectl create ns testauth

kubectl -n testauth apply -f samples/sleep/sleep.yaml

# 可以访问
kubectl -n testauth exec -it sleep-557747455f-g9wvf -c sleep -- curl http://httpbin.default:8000/ip

# 给default添加命名空间策略
# 兼容模式
kubectl apply -f - <<EOF
apiVersion: "security.istio.io/v1beta1"
kind: "PeerAuthentication"
metadata:
  name: "default"
  namespace: "default"
spec:
  mtls:
    mode: PERMISSIVE
EOF

# 可以访问
kubectl -n testauth exec -it sleep-557747455f-g9wvf -c sleep -- curl http://httpbin.default:8000/ip

# 严格模式
kubectl apply -f - <<EOF
apiVersion: "security.istio.io/v1beta1"
kind: "PeerAuthentication"
metadata:
  name: "default"
  namespace: "default"
spec:
  mtls:
    mode: STRICT
EOF

# 不可访问
kubectl -n testauth exec -it sleep-557747455f-g9wvf -c sleep -- curl http://httpbin.default:8000/ip

# 注入 istio 即可访问，istio 会自动管理证书
kubectl -n testauth apply -f <(istioctl kube-inject -f samples/sleep/sleep.yaml)

# 可以访问
kubectl -n testauth exec -it sleep-64cf84c646-zmgdk -c sleep -- curl http://httpbin.default:8000/ip
```

#### 30 | 授权策略：如何实现JWT身份认证与授权？

```sh
kubectl create ns testjwt

kubectl -n testjwt apply -f <(istioctl kube-inject -f samples/sleep/sleep.yaml)
kubectl -n testjwt apply -f <(istioctl kube-inject -f samples/httpbin/httpbin.yaml)

# 测试连通性(因为没有任何规则，可以通，返回200)
kubectl -n testjwt exec $(kubectl -n testjwt get pod -l app=sleep -o jsonpath={.items..metadata.name}) -c sleep -- curl "http://httpbin.testjwt:8000/ip" -s -o /dev/null -w "%{http_code}\n"

# 创建请求认证
kubectl apply -f - <<EOF
apiVersion: "security.istio.io/v1beta1"
kind: "RequestAuthentication"
metadata:
  name: "jwt-example"
  namespace: testjwt
spec:
  selector:
    matchLabels:
      app: httpbin
  jwtRules:
  - issuer: "testing@secure.istio.io"
    jwksUri: "https://raw.githubusercontent.com/malphi/geektime-servicemesh/master/c3-19/jwks.json"
EOF

# 测试连通性(不带token可以正常访问)
kubectl -n testjwt exec $(kubectl -n testjwt get pod -l app=sleep -o jsonpath={.items..metadata.name}) -c sleep -- curl "http://httpbin.testjwt:8000/headers" -H "Authorization: Bearer invalidToken" -s -o /dev/null -w "%{http_code}\n"

# 测试连通性(带错误token不可以正常访问，报401错误)
kubectl -n testjwt exec $(kubectl -n testjwt get pod -l app=sleep -o jsonpath={.items..metadata.name}) -c sleep -- curl "http://httpbin.testjwt:8000/headers" -s -o /dev/null -w "%{http_code}\n"

# 创建授权策略
kubectl apply -f - <<EOF
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: require-jwt
  namespace: testjwt
spec:
  selector:
    matchLabels:
      app: httpbin
  action: ALLOW
  rules:
  - from:
    - source:
       requestPrincipals: ["testing@secure.istio.io/testing@secure.istio.io"]
EOF

# 测试连通性(不带token不可以正常访问，报403错误)
kubectl -n testjwt exec $(kubectl -n testjwt get pod -l app=sleep -o jsonpath={.items..metadata.name}) -c sleep -- curl "http://httpbin.testjwt:8000/headers" -H "Authorization: Bearer invalidToken" -s -o /dev/null -w "%{http_code}\n"

# 测试连通性(带错误token不可以正常访问，报403错误)
kubectl -n testjwt exec $(kubectl -n testjwt get pod -l app=sleep -o jsonpath={.items..metadata.name}) -c sleep -- curl "http://httpbin.testjwt:8000/headers" -s -o /dev/null -w "%{http_code}\n"

# 解析token
TOKEN=$(curl https://raw.githubusercontent.com/malphi/geektime-servicemesh/master/c3-19/demo.jwt -s) && echo $TOKEN | cut -d '.' -f2 - | base64 --decode -

# 测试连通性(带正确token可以正常访问)
kubectl -n testjwt exec $(kubectl get pod -l app=sleep -n testjwt -o jsonpath={.items..metadata.name}) -c sleep -- curl "http://httpbin.testjwt:8000/headers" -H "Authorization: Bearer $TOKEN" -s -o /dev/null -w "%{http_code}\n"

```

### 卸载

```sh
# 从集群中完全卸载 Istio
istioctl x uninstall --purge
kubectl delete ns istio-system
```

### 参考资料

[ServerTLSSettings](https://istio.io/latest/docs/reference/config/networking/gateway/#ServerTLSSettings-TLSProtocol)
