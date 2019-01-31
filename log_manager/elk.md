# 日志归集(ELK)

## 最佳架构

![efk-architecture.webp](/images/efk-architecture.webp)

![efk-architecture2.webp](/images/efk-architecture2.webp)

## 开源项目

[elastic/beats/deploy/kubernetes/filebeat](https://github.com/elastic/beats/tree/master/deploy/kubernetes/filebeat)

[deviantony/docker-elk](https://github.com/deviantony/docker-elk)

[cocowool/k8s-go/elk](https://github.com/cocowool/k8s-go/tree/master/elk)

[mgxian/k8s-log](https://github.com/mgxian/k8s-log)

## 镜像仓库

[docker.elastic.co](https://www.docker.elastic.co/)

## kibana index 设置

使用：

```sh
filebeat-*
@timestamp
```

最终效果图：

![efk-kibana.png](/images/efk-kibana.png)

## 进展

目前 elk 已经在 k8s 内实现，与 kafka、logstash 的集成待后续进一步研究。在生产环境可以与现有的 efk 系统进行对接。

## 参考资料

[从零开始搭建K8S--如何监控K8S集群日志](https://blog.csdn.net/java_zyq/article/details/82179175)

[k8s日志收集实战](https://juejin.im/post/5b6eaef96fb9a04fa25a0d37)

[玩儿透围绕ELK体系大型日志分析集群方案设计.搭建.调优.管理](http://www.net-add.com/a/zidonghuayunwei/rizhifenxi/2017/0406/16.html)

[使用filebeat收集kubernetes容器日志](https://www.itread01.com/content/1542091509.html)

[ELK+Filebeat+Kafka+ZooKeeper 构建海量日志分析平台](https://www.cnblogs.com/saneri/p/8822116.html)

[ELK+Filebeat+Kafka+ZooKeeper 构建海量日志分析平台](http://blog.51cto.com/wangqh/2090276)

[部署FileBeat+logstash+elasticsearch集群+kibana](http://www.yfshare.vip/2017/11/04/部署FileBeat-logstash-elasticsearch集群-kibana)

[ELK+Filebeat 集中式日志解决方案详解](https://www.ibm.com/developerworks/cn/opensource/os-cn-elk-filebeat/index.html)

