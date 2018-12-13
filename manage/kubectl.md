# kubectl

## 安装 kubectl

[Install and Set Up kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

[kube-shell](https://github.com/cloudnativelabs/kube-shell)

### mac 安装 kubectl

```sh
brew install kubernetes-cli
brew install bash-completion
kubectl completion bash > $(brew --prefix)/etc/bash_completion.d/kubectl
pip3 install kube-shell
```

将集群的 /root/.kube/config 拷贝到 mac，即可管理集群了。

kubectl label nodes 10.0.43.33 k8s.wonhigh.cn/namespace=bst-petrel-st --overwrite
kubectl label nodes 10.0.43.9  k8s.wonhigh.cn/namespace=bst-petrel-st --overwrite

## 参考资料

[Overview of kubectl](https://kubernetes.io/docs/reference/kubectl/overview/)

