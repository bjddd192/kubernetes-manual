# prometheus

使用 v0.29.0 版本。

## 镜像下载

[quay.io](https://quay.io)

```sh
docker pull quay.io/coreos/configmap-reload:v0.0.1
docker pull quay.io/coreos/prometheus-config-reloader:v0.28.0
docker pull quay.io/coreos/prometheus-operator:v0.28.0
docker pull quay.io/prometheus/alertmanager:v0.16.0
docker pull quay.io/coreos/kube-rbac-proxy:v0.4.1
docker pull quay.io/coreos/kube-state-metrics:v1.5.0
docker pull gcr.mirrors.ustc.edu.cn/google-containers/addon-resizer-amd64:2.1
docker pull quay.io/prometheus/node-exporter:v0.17.0
docker pull quay.io/coreos/k8s-prometheus-adapter-amd64:v0.4.1
docker pull grafana/grafana:6.1.6
docker pull quay.io/prometheus/prometheus:v2.5.0
```

## github

在 Kubernetes 上创建/配置/管理 Prometheus 集群

[coreos/prometheus-operator](https://github.com/coreos/prometheus-operator)

[helm/charts/stable/prometheus-operator](https://github.com/helm/charts/tree/master/stable/prometheus-operator)

[camilb/prometheus-kubernetes](https://github.com/camilb/prometheus-kubernetes)

[yanghongfei/Kubernetes](https://github.com/yanghongfei/Kubernetes/tree/master/kube-prometheus/manifests/prometheus/prometheus_rules)

[grafana/kubernetes-app](https://github.com/grafana/kubernetes-app)

[cloudworkz/kube-eagle](https://github.com/cloudworkz/kube-eagle)

## 安装

```sh
git clone https://github.com/coreos/prometheus-operator
cd prometheus-operator
git branch -a
git tag
git checkout v0.29.0
cd contrib/kube-prometheus/manifests/
kubectl apply -f .
```

## 参考资料

[部署 Prometheus Operator 监控 Kubernetes 集群](https://blog.csdn.net/aixiaoyang168/article/details/81661459)

[Prometheus Operator 初体验](https://www.qikqiak.com/post/first-use-prometheus-operator/?utm_medium=hao.caibaojian.com&utm_source=hao.caibaojian.com)

[在 Kubernets 中手动安装 Prometheus](https://www.qikqiak.com/k8s-book/docs/52.Prometheus%E5%9F%BA%E6%9C%AC%E4%BD%BF%E7%94%A8.html)

[监控二进制的 kube-scheduler](https://www.jianshu.com/p/88d6c0975cfe)

[grafana-kubernetes-app 插件](https://blog.csdn.net/mailjoin/article/details/81389700)

[报警神器 AlertManager 的使用](https://mp.weixin.qq.com/s/ouycoQ5-opB6UA1nZuBV6w)

[如何更有效地利用和监测Kubernetes资源？](https://mp.weixin.qq.com/s/bZynrEdetHAeOLentIYthg)
