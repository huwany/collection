# how to install rancher 2.5.8+

## prapare docker images

* private registy
  
  > refer to: https://goharbor.io

* get scripts
  
  > refer to: http://mirror.rancher.cn
  
  ```bash
  export RANCHER_VERSION=v2.6.2
  
  wget http://rancher-mirror.rancher.cn/rancher/${RANCHER_VERSION}/rancher-save-images.sh
  wget http://rancher-mirror.rancher.cn/rancher/${RANCHER_VERSION}/rancher-load-images.sh
  wget http://rancher-mirror.rancher.cn/rancher/${RANCHER_VERSION}/rancher-images.txt
  sed -i -e '/^rancher/!d' rancher-images.txt
  chmod +x rancher-save-images.sh rancher-load-images.sh
  ```

* download and push images
  
  ```bash
  docker login hub.relay2.cn
  ./rancher-save-images.sh --from-aliyun true
  ./rancher-load-images.sh --registry hub.relay2.cn
  ```

## lunch kubernetes cluster

* install rke or refer to: https://rancher.com/docs/rke/latest/en/installation/

* create kubernetes cluster
  
  ```bash
  rke up
  ```

## add helm repo

* for global
  
  ```bash
  helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
  ```
  
  for China only
  
  ```bash
  helm repo add rancher-stable http://rancher-mirror.oss-cn-beijing.aliyuncs.com/server-charts/stable
  ```

* fetch the chart
  
  ```bash
  helm fetch rancher-stable/rancher
  ```

## create namespace

* create namespace
  
  ```bash
  kubectl create namespace cattle-system
  ```

## create secret

* create certificate secrets
  
  ```bash
  kubectl -n cattle-system create secret tls tls-rancher-ingress \
    --cert=tls.crt \
    --key=tls.key
  ```

## install from template

```bash
helm template rancher rancher-stable/rancher \
    --output-dir . \
    --no-hooks \
    --namespace cattle-system \
    --set rancherImage=hub.relay2.cn/rancher/rancher \
    --set hostname=k8s.cn.relay2.host \
    --set systemDefaultRegistry=hub.relay2.cn \
    --set ingress.tls.source=secret \
    --set ingress.enabled=true \
    --set replicas=1

kubectl -n cattle-system apply -R -f ./rancher
```

## install from helm

```bash
helm install rancher rancher-stable/rancher \
    --namespace cattle-system \
    --set rancherImage=hub.relay2.cn/rancher/rancher \
    --set hostname=k8s.cn.relay2.host \
    --set systemDefaultRegistry=hub.relay2.cn \
    --set ingress.tls.source=secret \
    --set ingress.enabled=true \
    --set replicas=1
    
helm install rancher rancher-stable/rancher \
    --namespace cattle-system \
    --create-namespace \
    --set hostname=rancher.dev.cn.relay2.host \
    --set tls=external \
    --set replicas=1
```

```bash
kubectl -n cattle-system create secret generic rancher-dashboard \
  --from-file=tls.crt=./rancher.dev.cn.relay2.host.crt \
  --from-file=tls.key=./rancher.dev.cn.relay2.host.key

---
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  name: rancher
  namespace: cattle-system
spec:
  entryPoints:
    - web
    - websecure
  routes:
  - match: Host(`rancher.dev.cn.relay2.host`)
    kind: Rule
    services:
    - name: rancher
      port: 80
  tls:
    secretName: rancher-dashboard
```
