# harbor 2.x

[官方文档](https://goharbor.io/docs)

### 安装部署

```sh
cd /tmp
wget http://10.0.43.24:8066/harbor/harbor-offline-installer-v2.4.0.tgz
tar zxvf harbor-offline-installer-v2.4.0.tgz
mv /tmp/harbor /data/
cd /data/harbor
# 配置 harbor
vi harbor.yml
# 配置 install，关闭自动启动 docker-compose
vi install.sh
# 调整网络
vi docker-compose.yml
# 初始化 harbor
# 要使用 Notary 进行安装，您必须将 Harbor 配置为使用 HTTPS。
# Harbor v2.1 及之前的版本内置了 Clair 镜像扫描器，在 v2.2 中，Harbor使用了 Aqua Trivy 作为缺省扫描器。
sh /data/harbor/install.sh --with-trivy --with-chartmuseum
# 启动 harbor
docker-compose up -d
# 停止 harbor
# docker-compose down -v

docker-compose down -v
sh /data/harbor/prepare --with-trivy --with-chartmuseum
docker-compose up -d
```

### 镜像迁移

[一文带你上手镜像搬运工具 Skopeo](https://mp.weixin.qq.com/s/TfG_NHXRmBV_V_grOvzesQ)

[image-syncer](https://github.com/AliyunContainerService/image-syncer/blob/master/README-zh_CN.md)

```sh
mkdir -p /data/image-syncer
cd /data/image-syncer
wget http://10.0.43.24:8066/harbor/image-syncer-v1.3.1-linux-amd64.tar.gz
tar -zxvf image-syncer-v1.3.1-linux-amd64.tar.gz
# 获得帮助信息
./image-syncer -h

# 设置配置文件为config.json，默认registry为registry.cn-beijing.aliyuncs.com
# 默认namespace为ruohe，并发数为6
./image-syncer --proc=6 --auth=./auth.json --images=./images.json --retries=3
```

### API处理

[Harbor 2.0 通过API删除指定Tag镜像](https://www.cnblogs.com/uglyliu/p/14318990.html)

### 异常处理

[harbor-db迁移后不断重启](https://github.com/goharbor/harbor/issues/15464)

### 参考资料

[Harbor UI界面使用](https://blog.csdn.net/QianLiStudent/article/details/109223643)

[Harbor v2.4 release and Distributed Tracing](https://goharbor.io/blog/harbor-2.4/)

[Harbor对接Ceph S3安装及使用手册](https://www.ethanzhang.xyz/harbor%E5%AF%B9%E6%8E%A5ceph-s3%E5%AE%89%E8%A3%85%E5%8F%8A%E4%BD%BF%E7%94%A8%E6%89%8B%E5%86%8C/)
