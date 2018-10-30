# harbor

Harbor 是一个用于存储和分发 Docker 镜像的企业级 Registry 服务器，通过添加一些企业必需的功能特性，例如安全、标识和管理等，扩展了开源 Docker Distribution。作为一个企业级私有 Registry 服务器，Harbor 提供了更好的性能和安全。提升用户使用 Registry 构建和运行环境传输镜像的效率。Harbor 支持安装在多个 Registry 节点的镜像资源复制，镜像全部保存在私有 Registry 中， 确保数据和知识产权在公司内部网络中管控。另外，Harbor 也提供了高级的安全特性，诸如用户管理，访问控制和活动审计等。

[Harbor 官网](https://github.com/goharbor/harbor)

[Harbor release](https://github.com/vmware/harbor/releases)

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

```

## 参考资料

[VMware Harbor 学习](https://www.cnblogs.com/biglittleant/p/7283738.html)

[安装harbor1.6 企业级镜像仓库](https://www.jianshu.com/p/a636f20280ad)

[Harbor容器镜像安全漏洞扫描详述和视频](http://www.sohu.com/a/196796706_609552)
