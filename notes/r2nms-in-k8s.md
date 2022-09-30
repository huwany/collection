# how to deploy r2nms in k8s

## deploy k8s cluster

```
see rancher section
```

## config charts

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
```

## deploy RabbitMQ

```console
helm install r2mq bitnami/rabbitmq \
    --namespace cnbeta02 \
    --set replicaCount=3 \
    --set auth.username=r2user \
    --set auth.password=r2password
    #--set loadDefinition.enabled=true \
    #--set loadDefinition.existingSecret=rabbitmq-load-definition \
    #--set extraConfiguration="management.load_definitions = /app/load_definition.json"
    #--set auth.erlangCookie=$RABBITMQ_ERLANG_COOKIE
```

## deploy Redis

```
helm install r2redis bitnami/redis \
    --namespace cnbeta02 \
    --set architecture=standalone \
    --set auth.enabled=false \
    --set auth.sentinel=false
```

## deploy MySQL

```
helm install r2db bitnami/mysql \
    --namespace cnbeta02 \
    --set image.registry=hub.relay2.cn \
    --set image.repository=nms/r2db \
    --set image.tag=100.0.0-20210928 \
    --set auth.rootPassword=mysql \
    --set primary.persistence.size=10Gi
```

```
helm install ~/Work/r2cloud-charts/r2cloud \
    --set global.nodeport.http=31021 \
    --set global.nodeport.https=31022 \
    --set global.route.webui=www.dev.relay2.cn \
    --set global.route.sp=sp.dev.relay2.cn \
    --set global.route.banner=srv.dev.relay2.cn \
    --set global.route.scm=scm.dev.relay2.cn \
    --set global.route.cwlc=cwlc.dev.relay2.cn \
    --set global.route.ac=ac.dev.relay2.cn \
    --set global.route.orbit=orbit.dev.relay2.cn \
    --set global.route.fu=fu.dev.relay2.cn \
    --set global.route.rssh=rssh.dev.relay2.cn \
    --set global.tag=100.0.0-20210928 \
    --set r2redis.enabled=false \
    --set r2mq.enabled=false \
    --set r2db.enabled=true \
    --set r2ldap.enabled=false \
    --set r2dsas.enabled=false \
    --set r2nms.enabled=false \
    --set r2webui.enabled=false \
    --set r2banner.enabled=false \
    --set r2fu.enabled=false \
    --set r2server.enabled=false \
    --set r2report.enabled=false \
    --set r2notification.enabled=false \
    --set r2clctr.enabled=false \
    --set r2heatmap.enabled=false \
    --set r2scm.enabled=false \
    --set r2caserver.enabled=false \
    --set r2tm.enabled=false \
    --set r2cwlc.enabled=false
```
