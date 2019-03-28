# 问题记录

## 别人分享的问题

Q：使用nfs有存在性能瓶颈或单点故障的问题嘛?如何解决，不如对于持久化要求高的Redis 应该采用哪种存储？
A：具体看你的规模数量，测试、开发环境，单节点nfs毫无压力,数据是先写到缓存内存，速度很快，非常稳写，我文章中的说的内核注意BUG，没必要做高可用，公有云有nas服务不必担心，自建机房可以用drbd Keepalived vip。

Q：为什么网络没有使用traefik,spring cloud的先关组件是怎么部署？是用yaml文件还是使用helm方式？
A：考虑到traefik性能没有nginx好，所以用nginx, ymal是自己写的模板生成，没有用helm,我们正在调研，eureka可以单独定制多个yml互相注册。与外部服务通过打通网络了直通，通过svc对接。


Q：用ceph的方案是ceph provision的方式还是csi plugins的方式，csi plugins好像在1.12.0以上版本才较好地支持，用ceph csi plugins的方式 有遇到性能或可靠性的问题嘛？如何解决？
A：我们现在用的是provision方式，没用csi plugins。

Q：目前有状态容器 statefulset 使用持久化的存储方案，nfs和ceph的方案 有上生产环境嘛？上生产环境的应用是Redis或者MySQL？生产上是否有遇到？
A：生产redis nfs是没问题，生产我们用的公有云，直接用的厂商的存储，ceph只用在测试、开发环境。

Q：用你说的日志方案，你们的集群规模以及服务规模大概是多大，每天可以产生多少日志呢？
A：每天日志1-2TB左右，es集群SSD可以随时扩容。

Q：脚本是通过什么语言开发的 ，能否共享一个例子
A：用shell脚本可以很容易完成，无非是awk sed 一些逻辑，最主要是要有思路，需要例子可以单独联系我，我可以指导。

Q：请问下所有环境都在一个集群，压测怎么办？
A：压测只是对应用产生压力，你可以把需要压测的应用调度到不同的节点NodeSelector隔离运行。

Q：对于局域网微信回调是如何做，没有公网ip
A：打通网络之后，设置wifi 指向dns为k8s-dns ，service直接互通。

Q：eureka注册时服务ip用的什么
A：k8s集群内会用的podip去注册。

Q：有状态应用的场景，使用容器部署与传统部署有啥区别？容器部署是否存在一些坑？
A：有状态容器创建后，尽量少动，少迁移，遇到过卡住，容器无法迁移或删除，重要的mysql之类的建议放外部运行。

Q：所有的环境都是跑在一个集群上面吗？
A：当然不是，我们有很多套k8s集群，跨公有云不同平台多个集群。

Q：我想请问一下新版本kubernetes可以兼容旧版本的kubernetes内容吗，可以在哪里查到详情吗?
A：k8s 官网，注意yaml api版本，新的一般兼容旧的api.

Q：你们在用Eureka做注册中心的时候 服务注册具体服务名称这么写的，得加上Eureka所在的namespace吧
A：服务注册用jar包名就可以，不需要namespace名。

## 别人的分享经验

公司原有运维系统缺点
原有业务布署在虚拟机ecs kvm ，脚本分散，日志分散难于集中收集管理，监控无法统一，cpu、内存、磁盘资源得用率低，运维效率极低，无法集中管理。
新业务布署需要开通新的虚拟机，需要单独定制监控，各种crontab ,配置脚本，效率低下，ci-cd jenkins配置繁琐。

k8s容器化优势
利用k8s容器平台namespaces对不同环境进行区分,建产不同dev、test 、stage、prod环境,实现隔离。
通过容器化集中布署所有业务，实现一键布署所需环境业务。
统一集中监控报警所有容器服务异常状态。
统一集中收集所有服务日志至elk集群, 利用kibana面板进行分类，方便开发查日志。
基于k8s命令行二次开发，相关开发、测试人员、直接操作容器。
基于rbac对不同的环境授于不同的开发、测试访问k8s权限，防止越权。
通过jenkins 统一ci-cd编译发布过程。
项目容器化后, 整体服务器cpu、 内存、磁盘、资源利用减少%50，运维效率提高%60，原来需要N个运维做的事，现在一个人即可搞定。

k8s本身是一套分布式系统，要用好会遇到很多问题，不是说三天两头就能搞定，需要具备网络、linux系统、存储，等各方面专业知识，在使用过程中我们也踩了不少坑, 我们是基于二进制方试安装，我们k8s版本为1.10，经过一段时间的实践，k8s对于我们整个开发、测试、发布、运维流程帮助非常大，值得大力推广。

网络方案选择
flanneld vxlan udp以及 hsot-gw 所有节点同步路由 ，使用简单，方便，稳定，k8s入门首选。
calico 基于BGP协议的路由方案，支持acl ，部署复杂，出现问题难排查。
Weave UDP广播，本机建立新的BR，通过PCAP互通 ，国内使用比较少。
Open vSwitch UDP广播，本机建立新的BR，通过PCAP互通，openshift 以及混合云使用比较多。

我们对各个网络组件进行过调研对比，网络方案选择的是flanneld-hostgw+ipvs，在k8s1.9之前是不支持ipvs，kube-proxy负责所有svc规则的同步，使用的iptables,一个service会产生n条iptables记录。如果svc增加到上万条，iptables-svc同步会很慢，得几分钟，使用ipvs之后，所有节点的svc由ipvs lvs来负载，更快，更稳定。而且简单方便，使用门槛低， host-gw会在所有节同步路由表，每个容器都分配了一个IP地址，可用于与同一主机上的其他容器进行通信。对于通过网络进行通信，容器与主机的IP地址绑定。flanneld-hostgw性能接近calico，相对来说falnneld配置布署比calico简单很多。顺便提下flanneld-vxlan这种方式，需要通过udp封包解包，效率较低，适用于一些私有云对网络封包有限制，禁止路由路由表添加等有限制的平台。

flanneld 通过为每个容器提供可用于容器到容器通信的IP来解决问题。它使用数据包封装来创建跨越整个群集的虚拟覆盖网络。更具体地说，flanneld为每个主机提供一个IP子网（默认为/ 24），Docker守护程序可以从中为每个主机分配IP。
flannel使用etcd来存储虚拟IP和主机地址之间的映射。一个flanneld守护进程在每台主机上运行，并负责维护ETCD信息和路由数据包。
在此提一下，在使用flannled使用过程中遇到过严重bug 即租约失效，flanneld会shutdown 节点 网络组件，节点网络直接崩掉，解决办法是设置永久租期：https://coreos.com/flannel/docs/latest/reservations.html#reservations

传统业务迁移至k8s遇到的问题和痛点，devops遇到问题？
使用k8s会建立两套网络，服务之间调用通过svc域名，默认网络、域名和现有物理网络是隔离的，开发，测试，运维无法像以前一样使用虚拟机一样，postman ip+端口 调试服务， 网络都不通，这些都是问题。

pod网络 和物理网络不通，windows办公电脑、linux虚拟机上现有的业务和k8s是隔离的。
svc网络 和物理网络不通，windows办公电脑、linux虚拟机上现有的业务和k8s是隔离的。
svc域名和物理网络不通，windows办公电脑、linux虚拟机上现有的业务和k8s是隔离的。
原有nginx 配置太多的location 几百层，不好迁移到ingress-nginx，ingress只支持简单的规则。
svc-nodeport访问，在所有node上开启端口监听，占用node节点端口资源，需要记住端口号。
ingress http 80端口， 必需通过域名引入，ingress http 80端口必需通过域名引入，原来简单nginx的location可以通过ingress引入。
tcp–udp–ingress tcp udp 端口访问需要配置一个ingress lb，很麻烦，要先规划好lb节点同样也需要仿问lb端口。
原有业务不能停，继续运行，同时要能兼容k8s环境,和k8s集群内服务互相通讯调用，网络需要通。

传统虚拟机架构我们只需要一个地址+端口直接访问调试各种服务，k8s是否能做到不用改变用户使用习惯，无感知使用呢？答案是打通devops全链路，像虚拟机一样访部k8s集群服务 , 我们打通k8s网络和物理网理直通，物理网络的dns域名直接调用k8s-dns域名服务直接互访，所有服务互通。公司原有业务和现有k8s集群无障碍互访。

配置一台k8s node节点机做路由转发，配置不需要太高，布署成路由器模式,所有外部访问k8s集群流量经该节点, 本机ip: 192.168.2.71 。

vim /etc/sysctl.conf
net.ipv4.ip_forward = 1


设置全网路由通告,交换机或者linux、windows主机加上静态路由，打通网络。

route add -net 172.20.0.0 netmask 255.255.0.0 gw 192.168.2.71
route add -net 172.21.0.0 netmask 255.255.0.0 gw 192.168.2.71

增加dns服务器代理，外部服务需要访问k8s svc域名，首先需要解析域名，k8s服务只对集群内部开放，此时需要外部要能调用kube-dns 53号端口，所有办公电脑，业务都来请求kube-dns肯定撑不住 ，实时上确实是撑不住，我们做过测试，此时需要配置不同的域名进行分流策略，公网域名走公网dns,内部.svc.cluster.local走kube-dns。

建立dns代理服务器，ingress建立一个nginx-ingress服务反代kube-dns,ingress-nginx绑定到dns节点运行，在节点上监听 dns 53 端口。

```sh
[root@master1 kube-dns-proxy-1.10]# cat tcp-services-configmap.yaml
kind: ConfigMap
apiVersion: v1
metadata:
  name: tcp-services
  namespace: ingress-nginx
data:
  53: “kube-system/kube-dns:53”
[root@master1 kube-dns-proxy-1.10]# cat udp-services-configmap.yaml
kind: ConfigMap
apiVersion: v1
metadata:
  name: udp-services
  namespace: ingress-nginx
data:
  53: “kube-system/kube-dns:53”
[root@master1 kube-dns-proxy-1.10]# cat ingress-nginx-deploy.yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: nginx-ingress-controller-dns
  namespace: ingress-nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ingress-nginx-dns
  template:
    metadata:
      labels:
        app: ingress-nginx-dns
      annotations:
        prometheus.io/port: ‘10254’
        prometheus.io/scrape: ‘true’
    spec:
      hostNetwork: true
      serviceAccountName: nginx-ingress-serviceaccount
      containers:
        - name: nginx-ingress-controller-dns
          image: registry-k8s.novalocal/public/nginx-ingress-controller:0.12.0
          args:
            - /nginx-ingress-controller
            - —default-backend-service=$(POD_NAMESPACE)/default-http-backend
           # - —configmap=$(POD_NAMESPACE)/nginx-configuration
            - —tcp-services-configmap=$(POD_NAMESPACE)/tcp-services
            - —udp-services-configmap=$(POD_NAMESPACE)/udp-services
            - —annotations-prefix=nginx.ingress.kubernetes.io
          env:
            - name: POD_NAME
              valueFrom:
                fieldRef:
                  fieldPath: metadata.name
            - name: POD_NAMESPACE
              valueFrom:
                fieldRef:
                  fieldPath: metadata.namespace
          ports:
          - name: http
            containerPort: 80
          #- name: https
          #  containerPort: 443
          livenessProbe:
            failureThreshold: 3
            httpGet:
              path: /healthz
              port: 10254
              scheme: HTTP
            initialDelaySeconds: 10
```

最简单快捷的方式是安装dnsmasq，当然你也可以用bind ,powerdn,croedn等改造，上游dns配置为上一步骤增加nginx-ingress dns的地址，所有办公，业务电脑全部设置dns为此机,dnsmasq.conf 配置分流策略。

no-resolv server=/local/192.168.1.97 server=114.114.114.114

完成以上步骤 k8s podip svcip svc域名和办公，现有ecs、虚拟机完美融合，无缝访问，容器网络问题搞定。
windows访问k8s svc畅通无组，开发测试，完美无缝对接。


k8s 日志方案
普通虚拟机日志分散，难管理，需要登陆虚拟机一个个查看，k8s-docker可以很方便帮我们收集管理日志，日志方案有几种。

应用打到docker stdout 前台输出，docker输出到/var/lib/containers, 通过filebeat、fluentd 、daemonsets组件收集，这种对于小量日志还可以，大量日志性能很差，写入很慢.
pod挂载host-path 把日志打到宿主机，宿主机启动filebeat， fluentd 、daemonsets 收集,无法判断来自哪个容器，pod namespaces。
pod的yml中定义两个 container ,同时启动一个附加的filebeat，两个container挂载一个共享卷来收集日志
我们用的第三种方案，通过一个附加容器filebeat来收集所有日志, filebeat–kakfa–logstash–es,自定义编译filebeat 镜相，为filebeat打上podip空间svc名等标签，方便识别来自哪个容器，哪个namespace，

filebeat----kafkacluster-----logstash----es

ilebeat收集日志打上关键字标签，namespace ，svc，podip 等

kibana 集中日志展示，建立dashboard分类，用户可以按namespce 分类不同环境，过滤选择查看不同模块的应用日志

简化kubectl 命 令, 提供给研发团队使用。实际上这里功能和jenkins以及kibana上是重复的，但是必需考虑到所有团队成员的使用感受，有人喜欢命令行，有人喜欢界面，简单好用就够。我打个比方，比如看日志，有人可能喜欢用命令行tail -f 看日志，用grep过滤等，有人喜欢用kibana看，那怎么办？于就有了两种方案，喜欢用图形界面的就去jenkins或kibana，你想用命令行的就给你命令行，满足你一切需求。统一集中通过指定的机器提供给开发、测试、运维、使用，方便调试，排障。通过统一的入口可以直接对容器进行服务创建，扩容，重启，登陆，查看日志，查看java启动参数 等，方便整个团队沟通。

在这里我们通过k8s rbac 授权身份认证 生产证书key kube-config key，授于不同项目组不同的管理权限，不同的项目组只有自己项目的权限，权限做了细分，不同研发、测试团队互不干扰。

## 其他问题

[kubernetes device or resource busy的问题](https://www.jianshu.com/p/4fc11a0a31da)

[kubernetes 1.9 与 CentOS 7.3 内核兼容问题](http://www.linuxfly.org/kubernetes-19-conflict-with-centos7/)

[一行 kubernetes 1.9 代码引发的血案（与 CentOS 7.x 内核兼容性问题）](http://dockone.io/article/4797)

[Cannot remove failed application deployments](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_1.2.0/getting_started/known_issues.html)

[Docker 报错Failed to watch directory … no space left on device](https://t.goodrain.com/t/docker-failed-to-watch-directory-no-space-left-on-device/472)

[k8s 1.9 kube-dns 服务端口不监听故障处理记录](https://blog.csdn.net/ywq935/article/details/80342267)

