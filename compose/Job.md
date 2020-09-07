### Job

```sh
# job.yaml
apiVersion: batch/v1
kind: Job
metadata:
  namespace: wonhigh-petrel-dev
  name: job-demo
spec:
  # 完成该Job需要执行成功的Pod数
  completions: 5
  # 能够同时运行的Pod数
  parallelism: 2
  # 允许执行失败的Pod数，默认值是6，0表示不允许Pod执行失败。
  # 如果Pod是restartPolicy为Nerver，则失败后会创建新的Pod
  # 如果是OnFailed，则会重启Pod，不管是哪种情况，只要Pod失败一次就计算一次，而不是等整个Pod失败后再计算一个。
  # 当失败的次数达到该限制时，整个Job随即结束，所有正在运行中的Pod都会被删除
  backoffLimit: 6
  # Job的超时时间，一旦一个Job运行的时间超出该限制，则Job失败，所有运行中的Pod会被结束并删除。
  # 该配置指定的值必须是个正整数。不指定则不会超时
  activeDeadlineSeconds: 300
  template:
    metadata:
      name: job-demo
    spec:
      # Job的RestartPolicy仅支持Never和OnFailure两种，不支持Always
      restartPolicy: Never
      containers:
      - name: counter
        image: busybox
        command:
        - "bin/sh"
        - "-c"
        - "for i in 9 8 7 6 5 4 3 2 1; do echo $i; done"
```

```sh
# 删除job
kubectl -n wonhigh-petrel-dev delete job job-demo

# 创建job
kubectl create -f job.yaml

# 查看pod
kubectl -n wonhigh-petrel-dev get po -a -o=wide | grep job-demo
```

### CronJob

创建的任务最好是幂等的。

```sh
# cronjob.yaml
apiVersion: batch/v2alpha1
kind: CronJob
metadata:
  namespace: wonhigh-petrel-dev
  name: cronjob-demo
spec:
  schedule: "*/1 * * * *"
  jobTemplate:
    spec:
      template:
        metadata:
          name: cronjob-demo
        spec:
          restartPolicy: OnFailure
          containers:
          - name: hello
            image: busybox
            args:
            - "bin/sh"
            - "-c"
            - "for i in 9 8 7 6 5 4 3 2 1; do echo $i; done"
```

```sh
# 删除job
kubectl -n wonhigh-petrel-dev delete cronjob cronjob-demo

# 创建job
kubectl create -f cronjob.yaml

# 查看job
kubectl -n wonhigh-petrel-dev get cronjob 

# 查看pod
kubectl -n wonhigh-petrel-dev get po -a -o=wide | grep cronjob-demo
```

### 参考资料

[k8s Job、Cronjob 的使用](https://www.cnblogs.com/lvcisco/p/9670100.html)
