# rbac

k8s里面有两种用户，一种是User，一种就是service account，User给人用的，service account给进程用的，让进程有相关的权限。

## 创建 namespace 普通用户

```sh
# 创建 ns
kubectl create namespace bst-scm-petrel-st

# 给 node 打上 ns 标签
kubectl label nodes 10.0.43.33 k8s.wonhigh.cn/namespace=bst-scm-petrel-st
kubectl label nodes 10.0.43.9 k8s.wonhigh.cn/namespace=bst-scm-petrel-st

# 调整证书文件
cd /etc/kubernetes/ssl
cp admin-csr.json user-bst-scm-petrel-st-csr.json
vim user-bst-scm-petrel-st-csr.json

# 生成证书
/root/local/bin/cfssl gencert \
	-ca=/etc/kubernetes/ssl/ca.pem \
	-ca-key=/etc/kubernetes/ssl/ca-key.pem \
	-config=/etc/kubernetes/ssl/ca-config.json \
	-profile=kubernetes user-bst-scm-petrel-st-csr.json | /root/local/bin/cfssljson -bare user-bst-scm-petrel-st

# 配置集群信息
kubectl config set-cluster kubernetes \
	--certificate-authority=/etc/kubernetes/ssl/ca.pem \
	--embed-certs=true \
	--server=https://10.0.43.251:8443 \
	--kubeconfig=user-bst-scm-petrel-st.kubeconfig

# 配置用户
kubectl config set-credentials user-bst-scm-petrel-st \
	--client-certificate=/etc/kubernetes/ssl/user-bst-scm-petrel-st.pem \
	--embed-certs=true \
	--client-key=/etc/kubernetes/ssl/user-bst-scm-petrel-st-key.pem \
	--kubeconfig=user-bst-scm-petrel-st.kubeconfig

# 配置上下文  
kubectl config set-context kubernetes \
	--cluster=kubernetes \
	--user=user-bst-scm-petrel-st \
	--namespace=bst-scm-petrel-st \
	--kubeconfig=user-bst-scm-petrel-st.kubeconfig

# 指定上下文  
kubectl config use-context kubernetes --kubeconfig=user-bst-scm-petrel-st.kubeconfig

# 覆盖默认的 kubeconfig 文件
\cp -f ./user-bst-scm-petrel-st.kubeconfig /root/.kube/config

# 将用户设置为该命名空间的管理员
kubectl create rolebinding user-bst-scm-petrel-st-binding --clusterrole=admin --user=user-bst-scm-petrel-st --namespace=bst-scm-petrel-st 

# 查看所有的集群角色，上面使用的是 admin 角色
kubectl get clusterroles

# 查看 token
kubectl -n=bst-scm-petrel-st describe secret $(kubectl -n=bst-scm-petrel-st get secret | grep user-bst-scm-petrel-st | awk '{print $1}')
 
```

## 参考资料

[创建用户认证授权的kubeconfig文件](https://jimmysong.io/kubernetes-handbook/guide/kubectl-user-authentication-authorization.html)

[kubernetes dashboard访问用户添加权限控制](https://www.cnblogs.com/fuyuteng/p/9501079.html)

[Managing Service Accounts](https://kubernetes.io/docs/reference/access-authn-authz/service-accounts-admin/)

[Creating sample user](https://github.com/kubernetes/dashboard/wiki/Creating-sample-user)

[kubernetes RBAC实战 kubernetes 用户角色访问控制](https://studygolang.com/articles/11730?fr=sidebar)

[为 Kubernetes 搭建支持 OpenId Connect 的身份认证系统](https://www.ibm.com/developerworks/cn/cloud/library/cl-lo-openid-connect-kubernetes-authentication/index.html)