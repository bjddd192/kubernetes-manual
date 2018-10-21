# kubernetes Volume

容器中的磁盘的生命周期是短暂的，这就带来了一系列的问题：
1. 当一个容器损坏之后，kubelet 会重启这个容器，但是文件会丢失-这个容器会是一个全新的状态。
2. 当很多容器在同一 Pod 中运行的时候，很多时候需要数据文件的共享。

Kubernete Volume 解决了这个问题。

一个 Kubernetes volume，拥有明确的生命周期，与所在的 Pod 的生命周期相同。如果这个 Pod 被删除了，那么这些数据也会被删除。

## Types of Volumes

Kubernete 支持如下类型的 volume：

- emptyDir
- hostPath
- gcePersistentDisk
- awsElasticBlockStore
- nfs
- iscsi
- glusterfs
- rbd
- gitRepo
- secret
- persistentVolumeClaim

### emptyDir

一个 emptyDir 第一次创建是在一个 Pod 被指定到具体 node 的时候，并且会一直存在在 Pod 的生命周期当中，正如它的名字一样，它初始化是一个空的目录，Pod 中的容器都可以读写这个目录，这个目录可以被挂在到各个容器相同或者不相同的的路径下。当一个 Pod 因为任何原因被移除的时候，这些数据会被永久删除。

**注意：一个容器崩溃了不会导致数据的丢失，因为容器的崩溃并不移除 Pod。**

emptyDir 磁盘的作用：

- 普通空间，基于磁盘的数据存储
- 作为从崩溃中恢复的备份点
- 存储那些那些需要长久保存的数据，例 web 服务中的数据

默认的，emptyDir 磁盘会存储在主机所使用的媒介上，可能是 SSD，或者网络硬盘，这主要取决于你的环境。当然，我们也可以将 emptyDir.medium 的值设置为 Memory 来告诉 Kubernetes 来挂载一个基于内存的目录 tmpfs，因为 tmpfs 速度会比硬盘快得多，但是，当主机重启的时候所有的数据都会丢失。

### hostPath

一个 hostPath 类型的磁盘就是挂载了主机的一个文件或者目录，这个功能可能不是那么常用，但是这个功能提供了一个很强大的突破口对于某些应用来说。

例如，如下情况我们就可能需要用到 hostPath：

- 某些应用需要用到 docker 的内部文件，这个时候只需要挂载本机的 /var/lib/docker 作为 hostPath
- 在容器中运行 cAdvisor，这个时候挂载 /dev/cgroups

当使用 hostPath 的时候要注意：从模版文件中创建的 pod 可能会因为主机上文件夹目录的不同而导致一些问题。

### gcePersistentDisk

GCE 谷歌云盘，暂时用不到。

### awsElasticBlockStore

aws 云盘，暂时用不到。

### nfs

nfs 使的我们可以挂载已经存在的共享到的我们的 Pod 中，和 emptyDir 不同的是，emptyDir 会被删除当我们的 Pod 被删除的时候，但是 nfs 不会被删除，仅仅是解除挂在状态而已，这就意味着 NFS 能够允许我们提前对数据进行处理，而且这些数据可以在 Pod 之间相互传递。并且，nfs 可以同时被多个 pod挂载并进行读写。

但需要注意 NFS 的网络存储效率比较低。不适合存在大批量读写操作的容器。

### iscsi

允许将现有的 iscsi 磁盘挂载到我们的 Pod 中。

### glusterfs

允许 Glusterfs 格式的开源磁盘挂载到我们的 Pod 中。

### rbd

允许 Rados Block Device 格式的磁盘挂载到我们的Pod中。

### gitRepo

gitRepo是一个磁盘插件的例子，它挂载了一个空的目录，并且将 git 上的内容 clone 到目录里供 pod 使用。

### Secrets

Secrets 磁盘是存储敏感信息的磁盘，例如密码之类。我们可以将 secrets 存储到 api 中，使用的时候以文件的形式挂载到 pod 中，而不用连接 api。Secrets 是通过 tmpfs 来支撑的，所以 secrets 永远不会存储到不稳定的地方。
