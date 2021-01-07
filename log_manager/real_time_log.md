# 实时日志处理

使用 `kubectl logs -f` 可以非常方便地集中查看集群当中各个 pod 的日志，但是通常需要看日志的是开发人员，而不是运维人员，kubectl 命令对集群管理的权限又很大，因此不可能将 kubectl 的权限开放给开发人员。经过分析，找到了方法，就是使用 rbash 来限制开发人员只能执行自定义的查看日志的命令，而不能进行其他任何操作。

大致步骤如下(需在任意一台安装有 kubectl 命令的集群机器上执行)：

## 添加一个查看日志的用户

```sh
adduser k8sloger
passwd k8sloger 
```

## 使用 rbash 限制用户部分权限

```sh
ln -s /bin/bash /bin/rbash
bash -c 'echo "/bin/rbash" >> /etc/shells'
chsh -s /bin/rbash k8sloger
```

## 回收日志用户所有的权限

```sh
bash -c 'echo "export PATH=/home/k8sloger/" >> /home/k8sloger/.bashrc'
```

## 赋予日志用户最基本的权限

```sh
ln -s /bin/ping /home/k8sloger/ping
ln -s /bin/ls /home/k8sloger/ls
ln -s /bin/grep /home/k8sloger/grep
ln -s /bin/wc /home/k8sloger/wc
ln -s /bin/awk /home/k8sloger/awk
ln -s /bin/sudo /home/k8sloger/sudo
```

## 添加 sudo 权限

```sh
visudo
# 手工添加以下内容
# k8sloger   ALL=NOPASSWD:  /root/local/bin/kubectl
```

## 添加查看日志的脚本

```sh
tee /home/k8sloger/getlog <<-'EOF'
#!/bin/sh

#sudo /root/local/bin/kubectl get namespace

read -p "请输入工程名:  " val 
result=$(sudo /root/local/bin/kubectl get pods --all-namespaces -o=wide | grep $val | awk '{printf("k8s%03d %s\n", NR, $0)}')

# 如果是echo $result，输出结果为一行，没有换行符
# 如果是echo "$result"，输出结果为多行，有换行符
# echo "$result"

count=$(echo "$result" | wc -l)
#echo $count
#echo "$result"

if [ "$result" = "" ]
then
        echo "未发现 Running 的POD，请检查"
else
        if [ "$count" = "1" ]
        then
                echo "发现一个 Running 的POD，即将输出日志..."
                namespace=$(echo "$result" | awk '{print $2}')
                podname=$(echo "$result" | awk '{print $3}')
                sudo /root/local/bin/kubectl logs -f --tail 1000 $podname  -n $namespace
        else
                # 如果是echo $result，输出结果为一行，没有换行符
                # 如果是echo "$result"，输出结果为多行，有换行符
                echo "$result"
                read -p "发现多个 Running 的POD，请输入 POD 序号:  " val
                podname=$(echo "$result" | grep $val | awk '{print $3}')
                namespace=$(echo "$result" | grep $val | awk '{print $2}')
                if [ -n "$namespace" ]
                then
                        sudo /root/local/bin/kubectl logs -f --tail 1000 $podname  -n $namespace
                else
                        echo "未发现 Running 的POD，请检查"
                fi
        fi
fi
EOF

chmod +x /home/k8sloger/getlog
```

## 应用方法

使用 `k8sloger` 用户 ssh 登陆到服务器(这里建议开发使用 webssh 登陆)，然后执行 `getlog` 命令根据提示进行操作，即可看到实时日志了。

## 参考资料

[想建一个用户只能执行几条命令](http://bbs.51cto.com/thread-1094531-1.html)

[rbash限制用户执行的命令](https://zzhaolei.github.io/2018/05/06/rbash%E9%99%90%E5%88%B6%E7%94%A8%E6%88%B7%E6%89%A7%E8%A1%8C%E7%9A%84%E5%91%BD%E4%BB%A4/)

[rbash - 一个受限的Bash Shell用实际示例说明](https://www.howtoing.com/rbash-a-restricted-bash-shell-explained-with-practical-examples/)
