# Ingress

## Træfɪk

[Træfɪk官网](http://traefik.cn/)

[入门教程](https://www.katacoda.com/courses/traefik/deploy-load-balancer)，有点晦涩难懂，网站不错。

入门试验：

```yaml
# docker-compose.yml

traefik:
  image: traefik
  command: --web --docker --docker.domain=docker.localhost --logLevel=DEBUG
  ports:
    - "80:80"
    - "8080:8080"
    - "443:443"
  volumes:
    - /var/run/docker.sock:/var/run/docker.sock
    - /dev/null:/traefik.toml

```

## 会话报错

```yaml
ingress.kubernetes.io /affinity: " cookie " 
```

## 参考资料

[IngressController的session stick问题](https://www.itread01.com/content/1511025635.html)
