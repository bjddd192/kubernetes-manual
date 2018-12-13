# rbac

k8s里面有两种用户，一种是User，一种就是service account，User给人用的，service account给进程用的，让进程有相关的权限。

## 创建 namespace 普通用户

master 操作

```sh
kubectl create namespace bst-petrel-st

# 给 node 节点设置命令空间
kubectl label nodes 10.0.43.33 k8s.wonhigh.cn/namespace=bst-petrel-st
kubectl label nodes 10.0.43.9 k8s.wonhigh.cn/namespace=bst-petrel-st

# 将用户设置为该命名空间的管理员
kubectl create rolebinding user-bst-petrel-st-binding --clusterrole=admin --user=user-bst-petrel-st --namespace=bst-petrel-st
```

root 操作：

```sh
adduser bst-petrel-st
passwd bst-petrel-st 

cp /root/local/bin/docker* /usr/local/bin/
cp /root/local/bin/kubectl /usr/local/bin/
usermod -G root bst-petrel-st

# 复制证书文件
cd /etc/kubernetes/ssl
cp admin-csr.json user-bst-petrel-st-csr.json
sed -i 's/admin/user-bst-petrel-st/g' user-bst-petrel-st-csr.json
sed -i 's/system:masters/k8s/g' user-bst-petrel-st-csr.json

# 生成证书
/root/local/bin/cfssl gencert \
-ca=/etc/kubernetes/ssl/ca.pem \
-ca-key=/etc/kubernetes/ssl/ca-key.pem \
-config=/etc/kubernetes/ssl/ca-config.json \
-profile=kubernetes user-bst-petrel-st-csr.json | /root/local/bin/cfssljson -bare user-bst-petrel-st
	
# 配置集群信息
kubectl config set-cluster kubernetes \
--certificate-authority=/etc/kubernetes/ssl/ca.pem \
--embed-certs=true \
--server=https://10.0.43.251:8443 \
--kubeconfig=user-bst-petrel-st.kubeconfig

chmod +r /etc/kubernetes/ssl/user-bst-petrel-st*

# 收回其他用户的执行权限
chmod 744 /root/local/bin/cfssl*

# 查看所有的集群角色
kubectl get clusterrole
```

bst-petrel-st 操作：

```sh
cd ~

\cp -f /etc/kubernetes/ssl/user-bst-petrel-st* /home/bst-petrel-st/

# 配置用户
kubectl config set-credentials user-bst-petrel-st \
--client-certificate=user-bst-petrel-st.pem \
--embed-certs=true \
--client-key=user-bst-petrel-st-key.pem \
--kubeconfig=user-bst-petrel-st.kubeconfig

# 配置上下文  
kubectl config set-context kubernetes \
--cluster=kubernetes \
--user=user-bst-petrel-st \
--namespace=bst-petrel-st \
--kubeconfig=user-bst-petrel-st.kubeconfig

# 指定上下文  
kubectl config use-context kubernetes --kubeconfig=user-bst-petrel-st.kubeconfig

# 覆盖默认的 kubeconfig 文件
\cp -f ./user-bst-petrel-st.kubeconfig ~/.kube/config

# 删除中间文件
rm -rf ~/user-bst-petrel-st*

# 查看 token
kubectl -n=bst-petrel-st describe secret $(kubectl -n=bst-petrel-st get secret | grep user-bst-petrel-st | awk '{print $1}')

```

## 参考资料

[创建用户认证授权的kubeconfig文件](https://jimmysong.io/kubernetes-handbook/guide/kubectl-user-authentication-authorization.html)

[kubernetes dashboard访问用户添加权限控制](https://www.cnblogs.com/fuyuteng/p/9501079.html)

[Managing Service Accounts](https://kubernetes.io/docs/reference/access-authn-authz/service-accounts-admin/)

[Creating sample user](https://github.com/kubernetes/dashboard/wiki/Creating-sample-user)

[kubernetes RBAC实战 kubernetes 用户角色访问控制](https://studygolang.com/articles/11730?fr=sidebar)

[为 Kubernetes 搭建支持 OpenId Connect 的身份认证系统](https://www.ibm.com/developerworks/cn/cloud/library/cl-lo-openid-connect-kubernetes-authentication/index.html)