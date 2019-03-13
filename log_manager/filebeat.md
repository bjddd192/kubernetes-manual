# filebeat

[官网](https://www.elastic.co/cn/)

[官方文档](https://www.elastic.co/cn/products/beats/filebeat)

[filebeat-input-docker](https://www.elastic.co/guide/en/beats/filebeat/current/filebeat-input-docker.html)

[Manage multiline messages](https://www.elastic.co/guide/en/beats/filebeat/current/multiline-examples.html)

[Regular expression support](https://www.elastic.co/guide/en/beats/filebeat/current/regexp-support.html)

[Add Kubernetes metadata](https://www.elastic.co/guide/en/beats/filebeat/current/add-kubernetes-metadata.html)

## filebeat 可以做什么

条目                 | filebeat
---------------------|---------
编写语言             | GO
是否支持多输出       | 支持
是否支持多输入       | 支持
是否支持修改日志内容 | 支持
是否会丢数据         | 不会
对多行文件的合并     | 支持
对多层目录的模糊匹配 | 支持
安装配置             | 简单
内存占用             | 10MB

## filebeat 安装

```sh
# 安装 es
docker pull docker.elastic.co/elasticsearch/elasticsearch:6.2.4

/sbin/sysctl -w vm.max_map_count=262144
  
docker stop elasticsearch && docker rm elasticsearch 

docker run -d --name elasticsearch --restart=always -p 9200:9200 -p 9300:9300 \
  --ulimit nofile=65536:65536 --ulimit memlock=-1:-1 \
  -e "bootstrap.memory_lock=true" \
  -e "discovery.type=single-node" \
  -e "ES_JAVA_OPTS=-Xms4g -Xmx4g" \
  docker.elastic.co/elasticsearch/elasticsearch:6.5.4

# 检查 es 健康状态：
curl http://127.0.0.1:9200/_cat/health

# 安装 kibana
docker stop kibana && docker rm kibana

docker run -d --name kibana --restart=always -p 30561:5601 \
  -e "ELASTICSEARCH_URL=http://10.68.0.7:9200" \
  docker.elastic.co/kibana/kibana:6.5.4

# 安装 filebeat
wget https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-6.5.4-x86_64.rpm
rpm -Uvh filebeat-6.5.4-x86_64.rpm
systemctl restart filebeat
```

## 常用命令

```sh
# 查看启用和禁用模块列表
filebeat modules list
```

## 参考资料

[Filebeat 快速开始](http://www.cnblogs.com/kerwinC/p/8866471.html)

[Elastic 技术栈之 Filebeat](https://www.cnblogs.com/jingmoxukong/p/8185321.html)

[ELK--filebeat详解](https://www.cnblogs.com/kuku0223/p/8316922.html)
