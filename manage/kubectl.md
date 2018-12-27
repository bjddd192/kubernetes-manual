# kubectl

## 安装 kubectl

[Install and Set Up kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

[kube-shell](https://github.com/cloudnativelabs/kube-shell)

### mac 安装 kubectl

```sh
brew info kubernetes-cli
brew search kubernetes-cli
brew install kubernetes-cli
brew install bash-completion
kubectl completion bash > $(brew --prefix)/etc/bash_completion.d/kubectl
pip3 install kube-shell

# 卸载
brew uninstall kubernetes-cli

# 指定版本安装(这个安装报错失败)
brew install https://github.com/Homebrew/homebrew-core/blob/d09d97241b17a5e02a25fc51fc56e2a5de74501c/Formula/kubernetes-cli.rb
# 采用二进制方式安装指定版本(需翻墙)
curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.9.6/bin/darwin/amd64/kubectl
chmod +x /Users/yanglei/Downloads/kubectl
mv /Users/yanglei/Downloads/kubectl /usr/local/bin/kubectl
```

将集群的 /root/.kube/config 拷贝到 mac，即可管理集群了。

kubectl label nodes 10.0.43.33 k8s.wonhigh.cn/namespace=bst-petrel-st --overwrite
kubectl label nodes 10.0.43.9  k8s.wonhigh.cn/namespace=bst-petrel-st --overwrite

## 参考资料

[Overview of kubectl](https://kubernetes.io/docs/reference/kubectl/overview/)

[Mac中使用brew安装指定版本软件包](https://segmentfault.com/a/1190000015346120?utm_source=tag-newest)

