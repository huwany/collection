# how to deploy ceph

## get source

* get source
  
  ```bash
  wget https://github.com/ceph/ceph-ansible/archive/refs/tags/v5.0.7.tar.gz
  tar xzvf v5.0.7.tar.gz
  ```
  
  or
  
  ```bash
  git clone https://github.com/ceph/ceph-ansible.git
  cd ceph-ansible
  git checkout stable-5.0
  ```

## install dependencies

* config pip (for China only)
  
  ```bash
  cat << EOF | sudo tee /etc/pip.conf
  [global]
  index-url = https://mirrors.aliyun.com/pypi/simple/
  
  [install]
  trusted-host=mirrors.aliyun.com
  EOF
  ```

* install dependencies
  
  ```bash
  sudo apt update
  sudo apt-get install -y python3-pip python3-dev
  sudo pip3 install -U pip
  sudo pip3 install -r requirements.txt
  ```

* config ssh
  
  ```bash
  cat << EOF | tee ~/.ssh/config
  Host *
      ServerAliveInterval 60
      StrictHostKeyChecking no
      IdentityFile ~/.ssh/hzdev
      User r2
  EOF
  ```

## prepare config file

* create inventory file
  
  ```bash
  cat << EOF > ~/ceph-ansible/cnhz.ini
  [all:vars]
  ansible_become=true
  ansible_become_method=sudo
  ansible_become_user=root
  interpreter_python=auto
  
  [mons]
  hz-node31
  hz-node32
  hz-node33
  
  [mgrs]
  hz-node31
  hz-node32
  hz-node33
  
  [osds]
  hz-node31
  hz-node32
  hz-node33
  
  #[mdss]
  #hz-node31
  #hz-node32
  #hz-node33
  
  #[rgws]
  #hz-node31
  #hz-node32
  #hz-node33
  
  #[grafana-server]
  #hz-node31
  EOF
  ```

* create all vars file
  
  ```bash
  cat << EOF > ~/ceph-ansible/group_vars/all.yml
  ---
  dummy:
  containerized_deployment: false
  configure_firewall: false
  ceph_origin: repository
  ceph_repository: community
  ceph_mirror: http://mirrors.aliyun.com/ceph
  ceph_stable_key: http://mirrors.aliyun.com/ceph/keys/release.asc
  ceph_stable_release: octopus
  ceph_stable_repo: "{{ ceph_mirror }}/debian-{{ ceph_stable_release }}"
  cephx: true
  monitor_interface: br-nas
  public_network: 10.20.90.0/24
  cluster_network: 10.20.91.0/24
  osd_objectstore: bluestore
  radosgw_civetweb_port: 8080
  radosgw_interface: br-nas
  dashboard_enabled: False
  #dashboard_protocol: http
  #dashboard_port: 8443
  #dashboard_network: "{{ public_network }}"
  #dashboard_admin_user: admin
  #dashboard_admin_password: cephpassw0rd
  #grafana_admin_user: admin
  #grafana_admin_password: cephpassw0rd
  ceph_conf_overrides:
    global:
      rbd_default_format: 2
      rbd_default_features: 3
    mon:
      mon_allow_pool_delete: true
      auth_allow_insecure_global_id_reclaim: false
  EOF
  ```

* create osd vars file
  
  ```bash
  cat << EOF > ~/ceph-ansible/group_vars/osds.yml
  ---
  dummy:
  devices:
    - /dev/sdb
    - /dev/sdc
    - /dev/sdd
    - /dev/sde
  EOF
  ```

* create other vars files
  
  ```bash
  cp ~/ceph-ansible/site.yml.sample ~/ceph-ansible/site.yml
  cp ~/ceph-ansible/site-container.yml.sample ~/ceph-ansible/site-container.yml
  cp ~/ceph-ansible/group_vars/clients.yml.sample ~/ceph-ansible/group_vars/clients.yml
  cp ~/ceph-ansible/group_vars/mons.yml.sample ~/ceph-ansible/group_vars/mons.yml
  cp ~/ceph-ansible/group_vars/mgrs.yml.sample ~/ceph-ansible/group_vars/mgrs.yml
  cp ~/ceph-ansible/group_vars/rgws.yml.sample ~/ceph-ansible/group_vars/rgws.yml
  cp ~/ceph-ansible/group_vars/mdss.yml.sample ~/ceph-ansible/group_vars/mdss.yml
  ```

## deploy

* deploy cluster
  
  ```bash
  cd ~/ceph-ansible
  ansible-playbook -i cnhz.ini site-container.yml
  ```
  
  or
  
  ```bash
  cd ~/ceph-ansible
  ansible-playbook -i cnhz.ini site.yml
  ```

## verify

* verify
  
  ```bash
  # ceph health
  HEALTH_OK
  ```

## operation

* cleanup
  
  ```bash
  ansible-playbook -i cnhz.ini infrastructure-playbooks/purge-container-cluster.yml
  ```
- adding osd(s), add osd node to inventory file
  
  ```bash
  ansible-playbook -vv -i cnhz.ini site.yml --limit node-04
  ```

- shrinking osd(s)
  
  ```bash
  ansible-playbook -vv -i cnhz.ini infrastructure-playbooks/shrink-osds.yml -e osd_to_kill=1,2,3
  ```
