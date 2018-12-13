# helm学习

[官网](https://www.helm.sh/)

[官方帮助文档](https://docs.helm.sh/using_helm/#installing-helm)

## 安装步骤

### 安装 helm 客户端(Linux)

```sh
wget http://10.0.43.24:8066/helm/helm-v2.11.0-linux-amd64.tar.gz
tar -zxvf helm-v2.11.0-linux-amd64.tar.gz 
mv linux-amd64/helm /usr/local/bin/helm
helm help
# 添加自动补全
source <(helm completion bash)
```

### 安装 helm 客户端(mac)

```sh
brew install kubernetes-helm
helm help
```

### 安装 helm 服务端 tiller

```sh
helm init --upgrade -i registry.cn-hangzhou.aliyuncs.com/google_containers/tiller:v2.11.0 --stable-repo-url https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts

# 为 Tiller 设置帐号
kubectl create serviceaccount --namespace kube-system tiller
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'

# 验证 Tiller 是否安装成功
kubectl get deploy --namespace kube-system tiller-deploy --output yaml|grep  serviceAccount
kubectl -n kube-system get pods|grep tiller
helm version
```

### 卸载 Helm 服务器端 Tiller

```sh
helm reset --help
helm reset
helm reset -f
# 移除 helm init 创建的目录等数据
helm reset --remove-helm-home
```

## helm 基本操作

```sh
# 创建示例 mychart
helm create mychart

# 检查依赖和模板配置是否正确
helm lint mychart

# 将应用打包
helm package mychart --debug

# helm serve 命令启动一个 Repository Server，
# 该 Server 缺省使用 $HOME/.helm/repository/local 目录作为 Chart 存储，并在 8879 端口上提供服务。
helm serve &

# 查看 helm Repository 信息
helm repo list

# 将本地 Repository 加入 Helm 的 Repo 列表
helm repo add local http://127.0.0.1:8879

# 查找包
helm search mychart

# 部署验证
helm install --dry-run --debug local/mychart --name mike-test

# 部署
helm install local/mychart --name mike-test

# 列出的所有已部署的 Release 以及其对应的 Chart
helm list

helm list -a --namespace=tsc

# 查询一个特定的 Release 的状态
helm status mike-test
```

## 与 harbor 仓库集成

```sh
# 安装 push 插件（可以因为网络的原因安装失败，多试几次）
helm plugin remove push
helm plugin install https://github.com/chartmuseum/helm-push

# 添加仓库
helm repo add --username scm --password n7izpoc6N2 repo-petrel http://hub.wonhigh.cn/chartrepo/petrel

# 推送 chart 到仓库
helm push --username scm --password n7izpoc6N2 mychart-0.1.0.tgz repo-petrel

# 更新仓库
helm repo update

# 查找 chart
helm search mychart

# 部署验证
helm install --dry-run --debug --username scm --password n7izpoc6N2 --version 0.1.0 repo-petrel/mychart --name mike-test

# 安装 chart
helm install --username scm --password n7izpoc6N2 --version 0.1.0 repo-petrel/mychart --name mike-test

# 升级版本
helm upgrade mike-test repo-petrel/mychart
helm upgrade mike-test --version 0.1.0 repo-petrel/mychart

# 查看历史
helm history mike-test

# 回滚版本
helm rollback mike-test 1

# 删除应用
helm delete mike-test

# 查看应用状态
helm ls -a mike-test
helm ls --deleted

# 移除指定 Release 所有相关的 Kubernetes 资源和 Release 的历史记录
helm delete --purge mike-test
```

## mustache

[mustache.github.io](https://mustache.github.io/)

### 模版对象说明

Release is one of the top-level objects that you can access in your templates。

- Release.Name: The release name
- Release.Time: The time of the release
- Release.Namespace: The namespace to be released into (if the manifest doesn’t override)
- Release.Service: The name of the releasing service (always Tiller).
- Release.Revision: The revision number of this release. It begins at 1 and is incremented for each helm upgrade.
- Release.IsUpgrade: This is set to true if the current operation is an upgrade or rollback.
- Release.IsInstall: This is set to true if the current operation is an install.

## 集成CI/CD

采用 Helm 可以把零散的 Kubernetes 应用配置文件作为一个 Chart 管理，Chart 源码可以和源代码一起放到 Git 库中管理。通过把 Chart 参数化，可以在测试环境和生产环境采用不同的 Chart 参数配置。

下图是采用了 Helm 的一个 CI/CD 流程：

![cicd](/images/cicd.png)

## Helm 如何管理多环境下 (Test、Staging、Production) 的业务配置

Chart 是支持参数替换的，可以把业务配置相关的参数设置为模板变量。使用 helm install 命令部署的时候指定一个参数值文件，这样就可以把业务参数从 Chart 中剥离了。例如： helm install --values=values-production.yaml wordpress。

## 参考资料

[Helm 入门指南](https://www.hi-linux.com/posts/21466.html)

[harbor-manage-helm-charts](https://github.com/goharbor/harbor/blob/master/docs/user_guide.md#manage-helm-charts)

[helm--chart模板文件简单语法使用](https://www.cnblogs.com/DaweiJ/articles/8779256.html)

[Helm简介](https://blog.csdn.net/chenleiking/article/details/79539012)
