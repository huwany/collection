# how to deploy kubernetes using kubespary

## on deploy host

* Prepare deploy host
  
  ```bash
  sudo apt update
  sudo apt install -y python3-pip git
  sudo pip3 install -U pip -i https://mirrors.aliyun.com/pypi/simple/
  ```
  
  ```bash
  cat << EOF > ~/.ssh/config
  Host *
      ServerAliveInterval 60
      StrictHostKeyChecking no
      IdentityFile ~/.ssh/hzdev
      User r2
  EOF
  ```
  
  ```bash
  scp ~/.ssh/hzdev devops.dev.relay2.host:.ssh/
  ```

* Get source
  
  ```bash
  git clone https://github.com/kubernetes-incubator/kubespray.git
  ```

* Disable auto apt upgrade
  
  ```bash
  cat << EOF | sudo tee /etc/apt/apt.conf.d/20auto-upgrades
  APT::Periodic::Update-Package-Lists "0";
  APT::Periodic::Download-Upgradeable-Packages "0";
  APT::Periodic::AutocleanInterval "0";
  APT::Periodic::Unattended-Upgrade "1";
  EOF
  ```

* Install dependencies
  
  ```bash
  cd ~/kubespray
  git checkout release-2.16
  sudo pip3 install -r requirements.txt -i https://mirrors.aliyun.com/pypi/simple/
  ```

* Prepare inventory
  
  ```bash
  cd ~/kubespray
  cp -rfp inventory/sample inventory/cnhz
  declare -a IPS=(10.20.10.101 10.20.10.102 10.20.10.103 10.20.10.104 10.20.10.105 10.20.10.106 10.20.10.107 10.20.10.108)
  CONFIG_FILE=inventory/cnhz/hosts.yaml python3 contrib/inventory_builder/inventory.py ${IPS[@]}
  ```

* Change kube version (optional)
  
  ```bash
  cd ~/kubespray
  sed -i -e 's/^kube_version:.*/kube_version: v1.19.11/g' \
      roles/kubespray-defaults/defaults/main.yaml \
      inventory/cnhz/group_vars/k8s_cluster/k8s-cluster.yml
  ```

* Prepare offline files  (optional, for China only)
  
  ```bash
  cd ~/kubespray/contrib/offline
  bash generate_list.sh
  wget -x -P files -i files.list
  ```

* Config offline environment (optional, for China only)
  
  ```bash
  cat << EOF > ~/kubespray/inventory/cnhz/group_vars/k8s_cluster/k8s-cluster.yml
  override_system_hostname: "false"
  files_repo: "http://repo.relay2.host/k8s_files"
  ubuntu_repo: "http://repo.relay2.host/ubuntu"
  
  #kube_image_repo: "registry.aliyuncs.com/google_containers"
  #gcr_image_repo: "registry.aliyuncs.com/google_containers"
  #docker_image_repo: "ee9kcv09.mirror.aliyuncs.com"
  #quay_image_repo: "quay.mirrors.ustc.edu.cn"
  
  kube_image_repo: "hub.relay2.cn/k8s.gcr.io"
  gcr_image_repo: "hub.relay2.cn/k8s.gcr.io"
  docker_image_repo: "hub.relay2.cn/docker.io"
  quay_image_repo: "hub.relay2.cn/quay.io"
  
  kubelet_download_url: "{{ files_repo }}/storage.googleapis.com/kubernetes-release/release/{{ kube_version }}/bin/linux/{{ image_arch }}/kubelet"
  kubectl_download_url: "{{ files_repo }}/storage.googleapis.com/kubernetes-release/release/{{ kube_version }}/bin/linux/{{ image_arch }}/kubectl"
  kubeadm_download_url: "{{ files_repo }}/storage.googleapis.com/kubernetes-release/release/{{ kubeadm_version }}/bin/linux/{{ image_arch }}/kubeadm"
  etcd_download_url: "{{ files_repo }}/github.com/coreos/etcd/releases/download/{{ etcd_version }}/etcd-{{ etcd_version }}-linux-{{ image_arch }}.tar.gz"
  cni_download_url: "{{ files_repo }}/github.com/containernetworking/plugins/releases/download/{{ cni_version }}/cni-plugins-linux-{{ image_arch }}-{{ cni_version }}.tgz"
  calicoctl_download_url: "{{ files_repo }}/github.com/projectcalico/calicoctl/releases/download/{{ calico_ctl_version }}/calicoctl-linux-{{ image_arch }}"
  calico_crds_download_url: "{{ files_repo }}/github.com/projectcalico/calico/archive/{{ calico_version }}.tar.gz"
  crictl_download_url: "{{ files_repo }}/github.com/kubernetes-sigs/cri-tools/releases/download/{{ crictl_version }}/crictl-{{ crictl_version }}-{{ ansible_system | lower }}-{{ image_arch }}.tar.gz"
  helm_download_url: "{{ files_repo }}/get.helm.sh/helm-{{ helm_version }}-linux-{{ image_arch }}.tar.gz"
  crun_download_url: "{{ files_repo }}/github.com/containers/crun/releases/download/{{ crun_version }}/crun-{{ crun_version }}-linux-{{ image_arch }}"
  kata_containers_download_url: "{{ files_repo }}/github.com/kata-containers/runtime/releases/download/{{ kata_containers_version }}/kata-static-{{ kata_containers_version }}-{{ ansible_architecture }}.tar.xz"
  nerdctl_download_url: "{{ files_repo }}/github.com/containerd/nerdctl/releases/download/v{{ nerdctl_version }}/nerdctl-{{ nerdctl_version }}-{{ ansible_system | lower }}-{{ image_arch }}.tar.gz"
  
  docker_ubuntu_repo_base_url: "http://mirrors.aliyun.com/docker-ce/linux/ubuntu"
  docker_ubuntu_repo_gpgkey: "http://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg"
  EOF
  ```

* Change cluster name
  
  ```bash
  cd ~/kubespray
  sed -i -e 's/^cluster_name:.*/cluster_name: cnhz.local/g' \
      inventory/cnhz/group_vars/k8s_cluster/k8s-cluster.yml
  ```

* Deploy
  
  ```bash
  cd ~/kubespray
  ansible-playbook -i inventory/cnhz/hosts.yaml -b cluster.yml
  ```