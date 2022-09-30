## deploy

## config
### ceph persistent storage
#### on ceph
* on each node
   ```bash
   apt install -y ceph-common
   ```

* create poll
  ```bash
  ceph osd pool create kube 512 512
  ceph osd pool application enable kube rbd
  ceph osd crush tunables hammer
  ```

* create kube user auth
  ```bash
  ceph auth get-or-create client.kube mon \ 
    'allow r' osd 'allow class-read object_prefix rbd_children, allow rwx pool=kube' \
    -o ceph.client.kube.keyring
  ```

* get secret
  ```bash
  ceph auth get-key client.admin | base64
  ceph auth get-key client.kube | base64
  ```
#### on k8s
* create admin secret
  ```bash
  ---
  apiVersion: v1
  type: kubernetes.io/rbd
  kind: Secret
  metadata:
    name: ceph-admin
    namespace: kube-system
  data: # echo -n 'YOUR_PASSWORD' | base64
    key: ADMIN_SECRET
  ```

* create user secret
  ```bash
  ---
  apiVersion: v1
  type: kubernetes.io/rbd
  kind: Secret
  metadata:
    name: ceph-kube
    namespace: default
  data: # echo -n 'YOUR_PASSWORD' | base64
    key: KUBE_SECRET
  ```
* create storageclass
  ```bash
  ---
  apiVersion: storage.k8s.io/v1
  kind: StorageClass
  metadata:
    name: ceph-rbd
    annotations:
      storageclass.kubernetes.io/is-default-class: "true"
  provisioner: kubernetes.io/rbd
  #provisioner: ceph.com/rbd
  reclaimPolicy: Delete
  volumeBindingMode: Immediate
  parameters:
    monitors: MON_HOST_1:6789,MON_HOST_2:6789,MON_HOST_3:6789
    adminId: admin
    adminSecretName: ceph-admin
    adminSecretNamespace: kube-system
    pool: kube
    userId: kube
    userSecretName: ceph-kube
    fsType: ext4
    imageFeatures: layering
  imageFormat: "2"
  ```