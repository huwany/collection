## system configuration

* system env

  ```bash
  Ubuntu 18.04 server or higher, 20.04 is recommended.
  ```

* config mirrors for **China Only**

  ```bash
  cat <<EOF | sudo tee /etc/apt/sources.list
  deb https://mirrors.ustc.edu.cn/ubuntu/ $(lsb_release -cs) main restricted universe multiverse
  # deb-src https://mirrors.ustc.edu.cn/ubuntu/ $(lsb_release -cs) main restricted universe multiverse
  deb https://mirrors.ustc.edu.cn/ubuntu/ $(lsb_release -cs)-security main restricted universe multiverse
  # deb-src https://mirrors.ustc.edu.cn/ubuntu/ $(lsb_release -cs)-security main restricted universe multiverse
  deb https://mirrors.ustc.edu.cn/ubuntu/ $(lsb_release -cs)-updates main restricted universe multiverse
  # deb-src https://mirrors.ustc.edu.cn/ubuntu/ $(lsb_release -cs)-updates main restricted universe multiverse
  deb https://mirrors.ustc.edu.cn/ubuntu/ $(lsb_release -cs)-backports main restricted universe multiverse
  # deb-src https://mirrors.ustc.edu.cn/ubuntu/ $(lsb_release -cs)-backports main restricted universe multiverse
  # deb https://mirrors.ustc.edu.cn/ubuntu/ $(lsb_release -cs)-proposed main restricted universe multiverse
  # deb-src https://mirrors.ustc.edu.cn/ubuntu/ $(lsb_release -cs)-proposed main restricted universe multiverse
  EOF
  
  curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo apt-key add -
  
  cat <<EOF | sudo tee /etc/apt/sources.list.d/docker-ce.list
  deb [arch=amd64] https://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable
  EOF
  
  curl -fsSL https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | sudo apt-key add -
  
  cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
  deb https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main
  EOF
  
  cat << EOF | sudo tee /etc/pip.conf
  [global]
  index-url = https://mirrors.aliyun.com/pypi/simple/
  
  [install]
  trusted-host=mirrors.aliyun.com
  EOF
  ```

* add helm apt repo

  ```bash
  curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
  
  cat <<EOF | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
  deb https://baltocdn.com/helm/stable/debian/ all main
  EOF
  ```

* install packages

  ```bash
  sudo apt update
  sudo apt install -y python3-pip kubectl helm
  
  source <(kubectl completion bash)
  kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl > /dev/null 2>&1
  
  source <(helm completion bash)
  helm completion bash | sudo tee /etc/bash_completion.d/helm > /dev/null 2>&1
  
  helm plugin install https://github.com/chartmuseum/helm-push
  ```

## deploy k3s server

* config environments
  ```bash
  export INSTALL_K3S_CHANNEL=stable
  export K3S_KUBECONFIG_OUTPUT=~/.kube/config
  export K3S_KUBECONFIG_MODE=644
  export K3S_RESOLV_CONF=/etc/rancher/k3s/resolv.conf
  export INSTALL_K3S_EXEC="server --docker --disable traefik"
  
  sudo mkdir -p /etc/rancher/k3s
  
  cat /run/systemd/resolve/resolv.conf | grep ^nameserver | sudo tee /etc/rancher/k3s/resolv.conf
  ```
  
* deploy server
  - for China only: 
  
    ```bash
    curl -sfL http://rancher-mirror.cnrancher.com/k3s/k3s-install.sh | INSTALL_K3S_MIRROR=cn sh -
    ```
    
  - for Global
    ```bash
    curl -sfL https://get.k3s.io | sh -
    ```

## add helm repo

* add bitnami repo

  ```bash
  helm repo add bitnami https://charts.bitnami.com/bitnami
  helm repo update bitnami
  ```

## deploy cert-manager

* deploy cert-manager

  ```bash
  helm install cert-manager bitnami/cert-manager \
    --namespace cert-manager \
    --create-namespace \
    --set installCRDs=true
  ```

* create issuer

  ```bash
  cat >cert-manager-issuer.yaml<< EOF
  ---
  apiVersion: cert-manager.io/v1
  kind: ClusterIssuer
  metadata:
    name: r2ca-cnhz
  spec:
    ca:
      secretName: r2ca-cnhz
  ---
  apiVersion: cert-manager.io/v1
  kind: ClusterIssuer
  metadata:
    name: le-prod
  spec:
    acme:
      email: devops@relay2.com
      server: https://acme-v02.api.letsencrypt.org/directory
      privateKeySecretRef:
        name: issuer-account-key-prod
      solvers:
      - http01:
          ingress:
            class: traefik
            ingressTemplate:
              metadata:
                annotations:
                  traefik.ingress.kubernetes.io/frontend-entry-points: websecure
                  traefik.ingress.kubernetes.io/router.tls: "true"
  ---
  apiVersion: cert-manager.io/v1
  kind: ClusterIssuer
  metadata:
    name: le-staging
  spec:
    acme:
      email: devops@relay2.com
      server: https://acme-staging-v02.api.letsencrypt.org/directory
      privateKeySecretRef:
        name: issuer-account-key-test
      solvers:
      - http01:
          ingress:
            class: traefik
            ingressTemplate:
              metadata:
                annotations:
                  traefik.ingress.kubernetes.io/frontend-entry-points: websecure
                  traefik.ingress.kubernetes.io/router.tls: "true"
  EOF
  
  kubectl -n cert-manager create secret tls r2ca-cnhz --cert=ca.crt --key=ca.key
  kubectl apply -f cert-manager-issuer.yaml
  ```

## deploy haproxy ingress controller

* add helm repo

  ```bash
  helm repo add haproxytech https://haproxytech.github.io/helm-charts
  helm repo update haproxytech
  
  cat > haproxy-ic-values.yaml<< EOF
  controller:
    kind: Deployment
    replicaCount: 1
    extraArgs:
      - --disable-ipv6
    logging:
      level: debug
    config:
       timeout-connect: "250ms"
       scale-server-slots: "1"
       dontlognull: "true"
       logasap: "true"
    service:
      type: LoadBalancer
      externalTrafficPolicy: Local
    extraEnvs:
      - name: TZ
        value: "Etc/UTC"
  defaultBackend:
    replicaCount: 1
    image:
      repository: mirrorgooglecontainers/defaultbackend-amd64
      tag: 1.5
  EOF
  ```

* deploy haproxy ingress controller

  ```bash
  helm install haproxy-ic haproxytech/kubernetes-ingress \
    --namespace haproxy-ic \
    --create-namespace \
    --values haproxy-ic-values.yaml
  ```
  
* or upgrade haproxy ingress controller

  ```bash
  helm upgrade --install haproxy-ic ./kubernetes-ingress-1.21.0.tgz \
    --namespace haproxy-ic \
    --create-namespace \
    --values haproxy-ic-values.yaml
  ```

## deploy traefik ingress controller

* add helm repo

  ```bash
  helm repo add traefik https://helm.traefik.io/traefik
  helm repo update traefik
  
  cat > traefik-values.yaml<< EOF
  ports:
    int:
      port: 9080
      expose: true
      exposedPort: 80
      protocol: TCP
    intsecure:
      port: 9443
      expose: true
      exposedPort: 443
      protocol: TCP
      tls:
        enabled: false
    web:
      port: 8000
      expose: true
      exposedPort: 8000
      protocol: TCP
    websecure:
      port: 8443
      expose: true
      exposedPort: 8443
      protocol: TCP
      tls:
        enabled: false
    smtp:
      port: 25
      expose: true
      exposedPort: 25
      protocol: TCP
  service:
    enabled: true
    type: LoadBalancer
    spec:
      externalTrafficPolicy: Local
  ingressRoute:
    dashboard:
      enabled: false
  additionalArguments:
    - --providers.kubernetesingress.ingressclass=traefik
    - --entrypoints.web.http.redirections.entryPoint.to=:443
    - --entrypoints.web.http.redirections.entryPoint.scheme=https
  EOF
  ```
  
* install traefik to cluster
  ```bash
  helm install traefik traefik/traefik \
    --namespace traefik \
    --create-namespace \
    --values traefik-values.yaml
  ```
  
* or upgrade traefik
  
  ```bash
  helm upgrade --install traefik traefik/traefik \
    --namespace traefik \
    --create-namespace \
    --values traefik-values.yaml
  ```
  
* create traefik dashboard ingress

  ```bash
  cat >traefik-dashboard.yaml<< EOF
  ---
  apiVersion: cert-manager.io/v1
  kind: Certificate
  metadata:
    name: traefik-dashboard-tls
    namespace: traefik
  spec:
    secretName: traefik-dashboard-tls
    issuerRef:
      group: cert-manager.io
      kind: ClusterIssuer
      name: r2ca-cnhz
    dnsNames:
    - traefik.cn.relay2.host
  ---
  apiVersion: traefik.containo.us/v1alpha1
  kind: IngressRoute
  metadata:
    name: traefik-dashboard
    namespace: traefik
  spec:
    entryPoints:
      - intsecure
    routes:
    - match: Host(\`traefik.cn.relay2.host\`)
      kind: Rule
      services:
      - name: api@internal
        kind: TraefikService
    tls:
      secretName: traefik-dashboard-tls
  EOF
  
  kubectl apply -f traefik-dashboard.yaml
  ```

## deploy rancher

* add helm repo

  ```bash
  helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
  helm repo update rancher-stable
  ```

* instll rancher

  ```bash
  helm install rancher rancher-stable/rancher \
      --namespace cattle-system \
      --create-namespace \
      --set bootstrapPassword=rancher \
      --set hostname=rancher.cn.relay2.host \
      --set tls=ingress \
      --set ingress.tls.source=secret \
      --set ingress.extraAnnotations.'kubernetes\.io/ingress\.class'=haproxy \
      --set ingress.extraAnnotations.'cert-manager\.io/cluster-issuer'=r2ca-cnhz \
      --set replicas=1
  ```

* or upgrade rancher

  ```bash
  helm upgrade --install rancher rancher-stable/rancher \
      --namespace cattle-system \
      --create-namespace \
      --set bootstrapPassword=rancher \
      --set hostname=rancher.cn.relay2.host \
      --set tls=ingress \
      --set ingress.tls.source=secret \
      --set ingress.extraAnnotations.'kubernetes\.io/ingress\.class'=haproxy \
      --set ingress.extraAnnotations.'cert-manager\.io/cluster-issuer'=r2ca-cnhz \
      --set replicas=1
  ```

* clean up rancher helm resources

  ```bash
  kubectl patch namespace cattle-system -p '{"metadata":{"finalizers":[]}}' --type='merge' -n cattle-system
  kubectl delete namespace cattle-system --grace-period=0 --force
  
  kubectl patch namespace cattle-global-data -p '{"metadata":{"finalizers":[]}}' --type='merge' -n cattle-system
  kubectl delete namespace cattle-global-data --grace-period=0 --force
  
  kubectl patch namespace cattle-global-data -p '{"metadata":{"finalizers":[]}}' --type='merge' -n cattle-system
  kubectl delete namespace cattle-global-data --grace-period=0 --force
  
  ```

## deploy repo

* create values file

  ```bash
  cat >repo-values.yaml<< EOF
  service:
    type: ClusterIP
  ingress:
    enabled: true
    tls: false
    annotations:
      kubernetes.io/ingress.class: traefik
      traefik.ingress.kubernetes.io/router.entrypoints: "int"
    hostname: repo.cn.relay2.host
  extraVolumeMounts:
    - name: repo
      mountPath: /app/repo
      readOnly: true
    - name: aptly
      mountPath: /app/ubuntu
      readOnly: true
  extraVolumes:
    - name: repo
      hostPath:
        path: /store/repo
        type: Directory
    - name: aptly
      hostPath:
        path: /store/aptly/public
        type: Directory
  serverBlock: |-
    server {
        listen 0.0.0.0:8080;
        server_name _;
        root /app/repo;
        location / {
            autoindex on;
            root /app/repo;
        }
        location /ubuntu {
            autoindex on;
            alias /app/ubuntu;
        }
        location ~ /(.*)/conf/ {
            deny all;
        }
        location ~ /(.*)/db/ {
            deny all;
        }
        location ~ /\.ht {
            deny all;
        }
    }
  EOF
  ```
  
* deploy repo

  ```bash
  helm install repo bitnami/nginx \
    --namespace repo \
    --create-namespace \
    --values repo-values.yaml
  ```

* or upgrade repo

  ```bash
  helm upgrade --install repo bitnami/nginx \
    --namespace repo \
    --create-namespace \
    --values repo-values.yaml
  ```

## deploy harbor

* create values file

  ```bash
  cat >harbor-values.yaml<< EOF
  externalURL: https://cr.relay2.cn
  adminPassword: relay2admin
  exposureType: ingress
  service:
    type: ClusterIP
  ingress:
    core:
      hostname: cr.relay2.cn
      tls: true
      annotations:
        kubernetes.io/ingress.class: "traefik"
        traefik.ingress.kubernetes.io/router.tls: "true"
        traefik.ingress.kubernetes.io/router.entrypoints: "websecure"
        cert-manager.io/cluster-issuer: "le-prod"
  persistence:
    persistentVolumeClaim:
      registry:
        size: 50Gi
  notary:
    enabled: false
  EOF
  ```
  
* deploy harbor

  ```bash
  helm install harbor bitnami/harbor \
    --namespace harbor \
    --create-namespace \
    --values harbor-values.yaml
  ```

* or upgrade harbor

  ```bash
  helm upgrade --install harbor bitnami/harbor \
    --namespace harbor \
    --create-namespace \
    --values harbor-values.yaml
  ```

## deploy postfix

* create postfix relay authentication info

  ```bash
  cat >outlook-auth.yaml<< EOF
  apiVersion: v1
  kind: Secret
  metadata:
    name: outlook-auth
  data:
    RELAY_FQDN: c210cC5yZWxheTIuY29t
    RELAY_HOST: cG9kNTEwMDkub3V0bG9vay5jb20=
    RELAY_PORT: NTg3
    RELAY_USER: ZGV2QHJlbGF5Mi5jb20=
    RELAY_PASS: UmVsYXkyQ2xvdWQ=
  EOF
  ```
  
  ```bahs
  kubectl create secret docker-registry cr-auth \
    --docker-server=<your-registry-server> \
    --docker-username=<your-name> \
    --docker-password=<your-pword> \
    --docker-email=<your-email>
  ```
  
  

## deploy k3s agent

* on server node

  ```bash
  sudo cat /var/lib/rancher/k3s/server/node-token
  ```
  
* on agent node

  ```bash
  export INSTALL_K3S_EXEC="agent --docker"
  export K3S_RESOLV_CONF=/etc/rancher/k3s/resolv.conf
  export K3S_URL="https://devops.dev.cn.relay2.host:6443"
  export K3S_TOKEN=${k3s_token}
  
  sudo mkdir -p /etc/rancher/k3s
  
  cat /run/systemd/resolve/resolv.conf | grep ^nameserver | sudo tee /etc/rancher/k3s/resolv.conf
  ```
  
* deploy agent

  - for China

    ```bash
    curl -sfL http://rancher-mirror.cnrancher.com/k3s/k3s-install.sh | INSTALL_K3S_MIRROR=cn sh -
    ```

  - for Global

    ```bash
    curl -sfL https://get.k3s.io | sh -
    ```
