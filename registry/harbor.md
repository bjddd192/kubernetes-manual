# harbor

Harbor 是一个用于存储和分发 Docker 镜像的企业级 Registry 服务器，通过添加一些企业必需的功能特性，例如安全、标识和管理等，扩展了开源 Docker Distribution。作为一个企业级私有 Registry 服务器，Harbor 提供了更好的性能和安全。提升用户使用 Registry 构建和运行环境传输镜像的效率。Harbor 支持安装在多个 Registry 节点的镜像资源复制，镜像全部保存在私有 Registry 中， 确保数据和知识产权在公司内部网络中管控。另外，Harbor 也提供了高级的安全特性，诸如用户管理，访问控制和活动审计等。

[Harbor 官网](https://github.com/goharbor/harbor)

[Harbor release](https://github.com/vmware/harbor/releases)

[用户指南](https://github.com/goharbor/harbor/blob/master/docs/user_guide.md)

[Installation & Configuration Guide](https://github.com/goharbor/harbor/blob/master/docs/installation_guide.md)

[Harbor on Kubernetes with Harbor chart](https://github.com/goharbor/harbor-helm)

[Configuring Harbor with HTTPS Access](https://github.com/goharbor/harbor/blob/master/docs/configure_https.md)

## 特性

- 云原生仓库：支持容器镜像和 Helm charts
- 基于角色的访问控制：用户与Docker镜像仓库通过“项目”进行组织管理，一个用户可以对多个镜像仓库在同一命名空间（project）里有不同的权限。
- 基于策略的镜像复制：可以基于具有多个过滤器的策略在多个仓库实例之间复制（同步）镜像。如果遇到任何错误，Harbor 将自动重试进行复制。非常适合负载平衡，高可用性，多数据中心，混合和多云场景。
- 漏洞扫描：Harbor 定期扫描镜像并警告用户漏洞。
- 图形化用户界面：用户可以通过浏览器来浏览，检索当前Docker镜像仓库，管理项目和命名空间。
- LDAP/AD 支持：Harbor可以集成企业内部已有的AD/LDAP，用于鉴权认证管理。
- 国际化：已拥有英文、中文、德文、日文和俄文的本地化版本。更多的语言将会添加进来。
- 镜像删除和垃圾收集：可以删除镜像，并可以回收它们的空间。
- RESTful API：适用于大多数管理操作的 RESTful API，易于与外部系统集成。
- 易于部署：提供在线和离线两种安装工具， 也可以安装到vSphere平台(OVA方式)虚拟设备。

## 安装步骤

```sh
cd /tmp
wget http://10.0.43.24:8066/harbor-offline-installer-v1.6.1.tgz
tar zxvf harbor-offline-installer-v1.6.1.tgz 
cd harbor
# 修改配置
# 启动 harbor
./install.sh

docker-compose -f ./docker-compose.yml -f ./docker-compose.clair.yml -f ./docker-compose.chartmuseum.yml down -v
docker-compose -f ./docker-compose.yml -f ./docker-compose.clair.yml -f ./docker-compose.chartmuseum.yml up -d
docker-compose -f ./docker-compose.yml -f ./docker-compose.clair.yml -f ./docker-compose.chartmuseum.yml up -d registry-web
```

## 权限管理

Harbor基于角色的访问控制，与 project 关联的角色简单地分为 Guest/Developer/Admin 三类，角色/project/镜像三者之间进行关联，不同角色的权限不同： 

角色         | 权限说明
-------------|--------------------------------------------------
Guest        | 对于指定项目拥有只读权限
Developer    | 对于指定项目拥有读写权限
ProjectAdmin | 除了读写权限，同时拥有用户管理/镜像扫描等管理权限

## 镜像回收

风险比较高，必须先备份数据，防止出现意外情况。

而且需要将仓库设置为只读，或者临时下线。

``` sh
cd /data/harbor
docker-compose stop
# The above option "--dry-run" will print the progress without removing any data
docker run -it --name gc --rm --volumes-from registry goharbor/registry:2.6.2-photon garbage-collect --dry-run /etc/registry/config.yml
docker run -it --name gc --rm --volumes-from registry goharbor/registry:2.6.2-photon garbage-collect  /etc/registry/config.yml
docker-compose start
```

实测结论：

1. 在界面软删除一个镜像，后端执行GC后，镜像空间可以回收，但是镜像的层并没有被删除，因此再次 push 会告知 `Layer already exists`
2. 由此可见，不能随意地去删除一个镜像，除非确定这个镜像所有的层都不会再用了(一般不好确定，因此不是很占空间的镜像就别删了)
3. 实际应用中，应该将最基础的镜像 push 到仓库中，永不删除，而代码构建的镜像都是基于基础镜像，在删除时只会删除代码构建的那一层，从而可以确保基础镜像层安全，同时要删除的也就是这些业务代码构建的镜像
4. 尽量不要删除所有镜像，至少保留最新的一个版本
5. 在删除镜像前要做好数据备份，镜像删除是一个容易出错的事情
6. 可以考虑使用镜像同步产生新的镜像仓库，将基础镜像同步过去，然后彻底抛弃老仓库
7. 可以考虑使用镜像同步做基础镜像备份

## Harbor API

自己写脚本扩展功能时非常重要：

```sh
# 查看镜像是否在存在于 harbor 仓库
curl -u "scm:n7izpoc6N2" -X GET -H "Content-Type: application/json" "http://hub.wonhigh.cn/api/repositories/petrel%2Fpetrel-register-center/tags/1.0.0-SNAPSHOT"
```

[HARBOR 仓库 API功能接口](https://www.cnblogs.com/guigujun/p/8352983.html)

[Harbor REST API说明](http://blog.51cto.com/dangzhiqiang/2097106)

## 问题

Q：管理员登录后没有管理员的操作权限？
A：清除浏览器缓存。

Q：仓库同步报错：hub.wonhigh.cn: no such host
A：需要处理 docker-compose.yml 文件，增加对 jobservice 服务的 extra_hosts 参数。

## 参考资料

[VMware Harbor 学习](https://www.cnblogs.com/biglittleant/p/7283738.html)

[安装harbor1.6 企业级镜像仓库](https://www.jianshu.com/p/a636f20280ad)

[Harbor容器镜像安全漏洞扫描详述和视频](http://www.sohu.com/a/196796706_609552)

[探索Harbor镜像仓库新的管理功能和界面](http://www.sohu.com/a/159993452_609552)

[Harbor最新资讯](http://mp.sohu.com/profile?xpt=aGVuZ2xpYmlqaUBzb2h1LmNvbQ==&_f=index_pagemp_1)

[Harbor实现容器镜像仓库的管理和运维](https://www.cnblogs.com/jicki/articles/5801510.html)

[Harbor基于角色的权限管理](https://blog.csdn.net/liumiaocn/article/details/81813666)

[Harbor镜像删除空间回收](https://blog.csdn.net/kong2030/article/details/81331142)

[删除Docker Registry里的镜像怎么那么难](http://qinghua.github.io/docker-registry-delete/)

[Harbor Registry Garbage Collect(垃圾回收)](http://www.itboth.com/d/u367vz/docker)

[docker-maven-plugin 完全免 Dockerfile 文件](https://www.cnblogs.com/atliwen/p/6101946.html)

[Docker镜像仓库Harbor主从镜像同步](https://blog.csdn.net/hiyun9/article/details/79655385)