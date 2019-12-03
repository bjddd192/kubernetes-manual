# calico

Calico组件：

- Felix：Calico agent，运行在每台node上，为容器设置网络信息：IP,路由规则，iptable规则等
- etcd：calico后端存储
- BIRD:  BGP Client： 负责把Felix在各node上设置的路由信息广播到Calico网络( 通过BGP协议)。
- BGP Route Reflector： 大规模集群的分级路由分发。
- calico： calico命令行管理工具

### 验证各Node间网络联通性

```sh
kubelet启动后主机上就生成了一个tunl0接口。
#第一台Node查看：
root@node1# ip route
192.168.77.192/26 via 10.3.1.17 dev tunl0  proto bird onlink 

#第二台Node查看：
root@node2# ip route
192.168.150.192/26 via 10.3.1.16 dev tunl0  proto bird onlink 

# 每台node上都自动设置了到其它node上pod网络的路由，去往其它节点的路都是通过tunl0接口，这就是IPIP模式。

# 如果设置CALICO_IPV4POOL_IPIP="off" ，即不使用IPIP模式，
# 则Calico将不会创建tunl0网络接口，路由规则直接使用物理机网卡作为路由器转发。
```

[Kubernetes之部署calico网络](https://blog.51cto.com/newfly/2062210)

[Calico网络不通的排查思路](https://mp.weixin.qq.com/s/MZIj_cvvtTiAfNf_0lpfTg)

[calico故障问题排查](https://www.jianshu.com/p/74ec7fc7cd08?t=123)

[Kubernetes多租户隔离利器-Calico](http://blog.itpub.net/31559359/viewspace-2217869/)

[calico 网络结合 k8s networkpolicy 实现租户隔离及部分租户下业务隔离](https://blog.csdn.net/qianggezhishen/article/details/80390598)

[k8s calico网络原理以及多租户实现设计](https://blog.csdn.net/ptmozhu/article/details/69645091)

[容器编排之Kubernetes多租户网络隔离](https://zhuanlan.zhihu.com/p/26614324)
