# 日志归集(EFK)

## ES数据定期删除

删除脚本：

```sh
#!/bin/bash
###################################
#删除早于2天的ES集群的索引
###################################
function delete_indices() {
    comp_date=`date -d "2 day ago" +"%Y-%m-%d"`
    date1="$1 00:00:00"
    date2="$comp_date 00:00:00"

    t1=`date -d "$date1" +%s` 
    t2=`date -d "$date2" +%s` 

    if [ $t1 -le $t2 ]; then
        echo "$1时间早于$comp_date，进行索引删除"
        #转换一下格式，将类似2017-10-01格式转化为2017.10.01
        format_date=`echo $1| sed 's/-/\./g'`
        curl -XDELETE http://172.20.32.78:32105/*$format_date
    fi
}

curl -XGET http://172.20.32.78:32105/_cat/indices | awk -F" " '{print $3}' | awk -F"-" '{print $NF}' | egrep "[0-9]*\.[0-9]*\.[0-9]*" | sort | uniq  | sed 's/\./-/g' | while read LINE
do
    #调用索引删除函数
    delete_indices $LINE
done
```



手工处理时区后时间显示不正确？
存储到ES的数据会有一个字段名为@timestamp，该时间戳和北京时间差了8小时，不需要进行调整，Kibana在展示的时候会自动加上8小时

[Kibana登录认证设置](https://www.cnblogs.com/configure/p/7607302.html)

[elasticsearch定期删除策略 - 日志分析系统ELK搭建](https://blog.csdn.net/xuezhangjun0121/article/details/80913678)

[玩儿透围绕ELK体系大型日志分析集群方案设计.搭建.调优.管理](http://www.net-add.com/a/zidonghuayunwei/rizhifenxi/2017/0406/16.html)

[从零开始搭建K8S--如何监控K8S集群日志](https://blog.csdn.net/java_zyq/article/details/82179175)
