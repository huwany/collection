# Deploy Openstack Victoria - kolla

## requirement

* Openstack Version
  
  ```bash
  Victoria
  ```

* Kolla Version
  
  ```bash
  11.0.0 (for Victoria Release)
  ```

* Deployment host
  
  ```bash
  ubuntu server 20.04.2
  ```

* Controller host
  
  ```bash
  ubuntu server 20.04.2
  ```

* Network host
  
  ```bash
  ubuntu server 20.04.2
  ```

* Compute host
  
  ```bash
  ubuntu server 20.04.2
  ```

## installation

### prepare deployment host

* config pip  (on deployment node)
  
  ```bash
  cat << EOF | sudo tee /etc/pip.conf
  [global]
  index-url = https://mirrors.aliyun.com/pypi/simple/
  
  [install]
  trusted-host=mirrors.aliyun.com
  EOF
  ```

* config ansible  (on deployment node)
  
  ```bash
  sudo mkdir -p /etc/ansible
  cat << EOF | sudo tee /etc/ansible/ansible.cfg
  [defaults]
  forks                   = 100
  poll_interval           = 15
  gathering               = smart
  transport               = smart
  pipelining              = True
  interpreter_python      = auto
  retry_files_enabled     = False
  host_key_checking       = False
  display_skipped_hosts   = False
  no_log                  = False
  local_tmp               = /tmp
  timeout                 = 30
  force_color             = 1
  
  [privilege_escalation]
  become=True
  become_method=sudo
  become_user=root
  become_ask_pass=False
  
  [paramiko_connection]
  record_host_keys = False
  
  [ssh_connection]
  ssh_args = -C -o ControlMaster=auto -o ControlPersist=1d -o UserKnownHostsFile=/dev/null
  pipelining = True
  scp_if_ssh = True
  EOF
  ```

* config ssh
  
  ```bash
  cat << EOF > ~/.ssh/config
  Host *
      ServerAliveInterval 60
      StrictHostKeyChecking no
      IdentityFile ~/.ssh/hzdev
      User r2
  EOF
  ```

* install  kolla (on deployment node)
  
  ```bash
  sudo apt update
  sudo apt-get install -y python3-pip python3-dev libffi-dev gcc libssl-dev
  sudo pip3 install -U pip
  sudo pip3 install 'ansible<2.10'
  sudo pip3 install kolla-ansible==11.0.0 openstackclient
  ```

* config kolla (on deployment node)
  
  ```bash
  cp -r /usr/local/share/kolla-ansible/etc_examples/kolla ~/
  cp /usr/local/share/kolla-ansible/ansible/inventory/multinode ~/kolla/
  
  mkdir -p ~/kolla/config/{cinder,glance,horizon,neutron,nova,octavia}
  mkdir -p ~/kolla/config/cinder/{cinder-backup,cinder-volume}
  
  cat << EOF | tee ~/kolla/config/{cinder,nova,glance}/ceph.conf
  [global]
  fsid = c87472de-f0f8-11ea-b16e-9b15e82d4f22
  mon_host = 10.20.90.31, 10.20.90.32, 10.20.90.33
  auth_cluster_required = cephx
  auth_service_required = cephx
  auth_client_required = cephx
  EOF
  
  sudo ln -sf ~/kolla /etc/kolla
  ```

### config ceph

* create pool (on ceph node)
  
  ```bash
  ceph osd pool create images 128
  ceph osd pool create volumes 128
  ceph osd pool create backups 128
  ceph osd pool create vms 128
  
  rbd pool init volumes
  rbd pool init images
  rbd pool init backups
  rbd pool init vms
  ```

* create auth user (on ceph node)
  
  ```bash
  ceph auth get-or-create \
      client.glance \
      mon 'profile rbd' \
      osd 'profile rbd pool=images' \
      mgr 'profile rbd pool=images' \
      -o /etc/ceph/ceph.client.glance.keyring
  
  ceph auth get-or-create \
      client.cinder \
      mon 'profile rbd' \
      osd 'profile rbd pool=volumes, profile rbd pool=vms, profile rbd-read-only pool=images' \
      mgr 'profile rbd pool=volumes, profile rbd pool=vms' \
      -o /etc/ceph/ceph.client.cinder.keyring
  
  ceph auth get-or-create \
      client.cinder-backup \
      mon 'profile rbd' \
      osd 'profile rbd pool=backups' \
      mgr 'profile rbd pool=backups' \
      -o /etc/ceph/ceph.client.cinder-backup.keyring
  ```

* copy ceph auth keyring
  
  ```bash
  export KOLLA_ADMIN_NODE='192.168.20.200'
  export KOLLA_ADMIN_KEY='/home/r2/.ssh/hzdev'
  
  scp -i ${KOLLA_ADMIN_KEY} \
      /etc/ceph/ceph.conf \
      r2@${KOLLA_ADMIN_NODE}:~/kolla/config/glance
  
  scp -i ${KOLLA_ADMIN_KEY} \
      /etc/ceph/ceph.conf \
      r2@${KOLLA_ADMIN_NODE}:~/kolla/config/cinder
  
  scp -i ${KOLLA_ADMIN_KEY} \
      /etc/ceph/ceph.conf \
      r2@${KOLLA_ADMIN_NODE}:~/kolla/config/nova
  
  scp -i ${KOLLA_ADMIN_KEY} \
      /etc/ceph/ceph.client.glance.keyring \
      r2@${KOLLA_ADMIN_NODE}:kolla/config/glance/
  
  scp -i ${KOLLA_ADMIN_KEY} \
      /etc/ceph/ceph.client.cinder.keyring \
      r2@${KOLLA_ADMIN_NODE}:kolla/config/cinder/cinder-volume/
  
  scp -i ${KOLLA_ADMIN_KEY} \
      /etc/ceph/ceph.client.cinder.keyring \
      r2@${KOLLA_ADMIN_NODE}:kolla/config/cinder/cinder-backup/
  
  scp -i ${KOLLA_ADMIN_KEY} \
      /etc/ceph/ceph.client.cinder-backup.keyring \
      r2@${KOLLA_ADMIN_NODE}:kolla/config/cinder/cinder-backup/
  
  scp -i ${KOLLA_ADMIN_KEY} \
      /etc/ceph/ceph.client.cinder.keyring \
      r2@${KOLLA_ADMIN_NODE}:kolla/config/nova/
  ```

## deploy Openstack

* preparation
  
  ```bash
  kolla-genpwd
  ```

* change password
  
  ```bash
  sed -i -e 's/^keystone_admin_password.*/keystone_admin_password: relay2cloud/g' ~/kolla/passwords.yml
  ```

* create globals.yml
  
  ```bash
  cat << EOF | tee ~/kolla/globals.yml
  ---
  kolla_base_distro: "ubuntu"
  kolla_install_type: "binary"
  openstack_release: "victoria"
  node_custom_config: "/etc/kolla/config"
  kolla_internal_vip_address: "10.20.20.200"
  docker_registry: hub.relay2.cn
  docker_registry_username: operator@server.local
  network_interface: "brmgmt"
  kolla_external_vip_interface: "{{ network_interface }}"
  api_interface: "{{ network_interface }}"
  storage_interface: "{{ network_interface }}"
  dns_interface: "{{ network_interface }}"
  network_address_family: "ipv4"
  api_address_family: "{{ network_address_family }}"
  storage_address_family: "{{ network_address_family }}"
  migration_address_family: "{{ api_address_family }}"
  dns_address_family: "{{ network_address_family }}"
  neutron_external_interface: "bond0"
  neutron_plugin_agent: "linuxbridge"
  keepalived_virtual_router_id: "51"
  enable_openstack_core: "yes"
  enable_haproxy: "yes"
  enable_chrony: "yes"
  enable_cinder: "yes"
  enable_cinder_backup: "yes"
  enable_designate: "yes"
  external_ceph_cephx_enabled: "yes"
  ceph_glance_keyring: "ceph.client.glance.keyring"
  ceph_glance_user: "glance"
  ceph_glance_pool_name: "images"
  ceph_cinder_keyring: "ceph.client.cinder.keyring"
  ceph_cinder_user: "cinder"
  ceph_cinder_pool_name: "volumes"
  ceph_cinder_backup_keyring: "ceph.client.cinder-backup.keyring"
  ceph_cinder_backup_user: "cinder-backup"
  ceph_cinder_backup_pool_name: "backups"
  ceph_nova_keyring: "{{ ceph_cinder_keyring }}"
  ceph_nova_user: "cinder"
  ceph_nova_pool_name: "vms"
  keystone_token_provider: 'fernet'
  keystone_admin_user: "admin"
  keystone_admin_project: "admin"
  glance_backend_ceph: "yes"
  cinder_backend_ceph: "yes"
  cinder_backup_driver: "ceph"
  designate_backend: "bind9"
  designate_ns_record: "relay2.host"
  nova_backend_ceph: "yes"
  nova_compute_virt_type: "kvm"
  EOF
  ```

* deploy
  
  ```bash
  kolla-ansible -i /etc/kolla/multinode bootstrap-servers
  kolla-ansible -i /etc/kolla/multinode prechecks
  kolla-ansible -i /etc/kolla/multinode pull
  kolla-ansible -i /etc/kolla/multinode deploy
  kolla-ansible -i /etc/kolla/multinode post-deploy
  ```

## manage Openstack

### create generic configurations

* create openrc file
  
  ```bash
  sudo chown r2:r2 /etc/kolla/admin-openrc.sh
  ```
- source admin rc file
  
  ```bash
  . /etc/kolla/admin-openrc.sh
  ```
* create ssh public key pairs
  
  ```bash
  openstack keypair create --public-key ~/.ssh/hzdev.pub hzdev
  ```

* create images
  
  ```bash
  mkdir ~/images
  
  cat << EOF | tee ~/images/images.list
  http://repo.cnhz.relay2.host/images/cirros/0.5.2/cirros-0.5.2-x86_64-disk.img
  http://repo.cnhz.relay2.host/images/uec/trusty-server-cloudimg-amd64-disk1.img
  http://repo.cnhz.relay2.host/images/uec/xenial-server-cloudimg-amd64-disk1.img
  http://repo.cnhz.relay2.host/images/uec/bionic-server-cloudimg-amd64.img
  http://repo.cnhz.relay2.host/images/uec/focal-server-cloudimg-amd64.img
  EOF
  
  wget -c -P ~/images -i ~/images/images.list
  
  openstack image create \
      --public \
      --progress \
      --container-format bare \
      --disk-format qcow2 \
      --property os_type=linux \
      --file ~/images/cirros-0.5.2-x86_64-disk.img \
      cirros
  
  openstack image create \
      --public \
      --progress \
      --container-format bare \
      --disk-format qcow2 \
      --property os_type=linux \
      --file ~/images/trusty-server-cloudimg-amd64-disk1.img \
      ubuntu1404
  
  openstack image create \
      --public \
      --progress \
      --container-format bare \
      --disk-format qcow2 \
      --property os_type=linux \
      --file ~/images/xenial-server-cloudimg-amd64-disk1.img \
      ubuntu1604
  
  openstack image create \
      --public \
      --progress \
      --container-format bare \
      --disk-format qcow2 \
      --property os_type=linux \
      --file ~/images/bionic-server-cloudimg-amd64.img \
      ubuntu1804
  
  openstack image create \
      --public \
      --progress \
      --container-format bare \
      --disk-format qcow2 \
      --property os_type=linux \
      --file ~/images/focal-server-cloudimg-amd64.img \
      ubuntu2004
  ```

* create flavor
  
  ```bash
  openstack flavor create --id 1 --ram 512 --disk 10 --vcpus 1 m1.tiny
  openstack flavor create --id 2 --ram 2048 --disk 20 --vcpus 1 m1.small
  openstack flavor create --id 3 --ram 4096 --disk 40 --vcpus 2 m1.medium
  openstack flavor create --id 4 --ram 8192 --disk 80 --vcpus 4 m1.large
  openstack flavor create --id 5 --ram 16384 --disk 160 --vcpus 8 m1.xlarge
  ```

* create user data
  
  ```bash
  cat << EOF | tee /etc/kolla/user_data_cn.txt
  #cloud-config
  disable_ec2_metadata: true
  disable_root: true
  users:
    - default
  system_info:
    distro: ubuntu
    default_user:
      name: r2
      lock_passwd: True
      gecos: Relay2 Cloud
      groups: [adm, audio, cdrom, dialout, dip, floppy, netdev, plugdev, sudo, video]
      sudo: ['ALL=(ALL) NOPASSWD:ALL']
      shell: /bin/bash
  runcmd:
    - find /etc/apt/sources.list.d -name 'ubuntu-esm*' -exec sed -i -e '/^deb/s/^/#/g' {} \;
  write_files:
    - content: |
        APT::Periodic::Update-Package-Lists '5';
        APT::Periodic::Download-Upgradeable-Packages '0';
        APT::Periodic::AutocleanInterval '0';
        APT::Periodic::Unattended-Upgrade '0';
      path: /etc/apt/apt.conf.d/10periodic
      permissions: '0644'
    - content: |
        APT::Periodic::Update-Package-Lists '5';
        APT::Periodic::Download-Upgradeable-Packages '0';
        APT::Periodic::AutocleanInterval '0';
        APT::Periodic::Unattended-Upgrade '0';
      path: /etc/apt/apt.conf.d/20auto-upgrades
      permissions: '0644'
    - content: |
        export LANG=en_US.UTF-8
        export LC_ALL=en_US.UTF-8
        export LC_CTYPE=en_US.UTF-8
      path: /etc/profile.d/set_locale.sh
      permissions: '0755'
    - content: |
        # !!!
        * soft nofile 65536
        * hard nofile 65536
        # eof.
      path: /etc/security/limits.d/r2limits.conf
      permissions: '0644'
    - content: |
        #!/bin/sh
        #
        echo
        echo '  /R2R2R2R                  /R2                             /R2R2R2R ';
        echo ' | R2__  R2                | R2                            /R2__   R2';
        echo ' | R2  \ R2      /R2R2R2   | R2    /R2R2R2    /R2   /R2   |__/    \R2';
        echo ' | R2R2R2R/     /R2__  R2  | R2   |_____ R2  | R2  | R2     /R2R2R2/' ;
        echo ' | R2__  R2    | R2R2R2R2  | R2    /R2R2R2R  | R2  | R2    /R2____/  ';
        echo ' | R2  \ R2    | R2_____/  | R2   /R2__  R2  | R2  | R2  | R2        ';
        echo ' | R2    | R2  |  R2R2R2R  | R2  |  R2R2R2R  |  R2R2R2R  | R2R2R2R2R2';
        echo ' |__/    |__/   \_______/  |__/   \_______/   \____  R2   |________/ ';
        echo '                                              /R2  | R2              ';
        echo '                                              | R2R2R2/              ';
        echo '                                               \_____/               ';
        echo
        echo ' * Welcome to Relay2 Cloud Computing Platform'
        echo
      path: /etc/update-motd.d/99-relay2
      permissions: '0755'
  apt_mirror: http://mirrors.ustc.edu.cn/ubuntu
  apt:
    primary:
      - arches: [default]
        uri: http://mirrors.ustc.edu.cn/ubuntu
  EOF
  ```

### create project and configurations

- create projects
  
  ```bash
  openstack project create --parent admin dev
  openstack role add --project dev --user admin admin
  ```
* create networks for project
  
  ```bash
  openstack network create \
      --project dev \
      --default \
      --provider-segment 807 \
      --provider-network-type vlan \
      --provider-physical-network provider \
      --dns-domain dev.relay2.host. \
      vlan807
  
  openstack subnet create \
      --project dev \
      --dhcp \
      --network vlan807 \
      --allocation-pool start=10.20.7.100,end=10.20.7.200 \
      --subnet-range 10.20.7.0/24 \
      --dns-nameserver 192.168.20.5 \
      --gateway 10.20.7.254 \
      vlan807-subnet
  ```

* create  security rules for project
  
  ```bash
  SEC_GROUP_ID=$(openstack security group list --project dev -c ID -f value)
  
  openstack security group rule create \
      --project dev --ethertype IPv4 \
      --protocol icmp ${SEC_GROUP_ID}
  
  openstack security group rule create \
      --project dev --ethertype IPv4 \
      --protocol tcp --dst-port 22 ${SEC_GROUP_ID}
  ```

* increase the quota for project
  
  ```bash
  openstack quota set --instances 20 dev
  openstack quota set --cores 20 dev
  openstack quota set --ram 50000 dev
  ```

## create instance

- prepare rc file
  
  ```bash
  cp /etc/kolla/admin-openrc.sh /etc/kolla/openrc-dev.sh
  sed -i -e 's/OS_PROJECT_NAME=.*/OS_PROJECT_NAME=dev/g' /etc/kolla/openrc-dev.sh
  ```

- source rc file
  
  ```bash
  . /etc/kolla/openrc-dev.sh
  ```

- create dns zone
  
  ```bash
  openstack zone create --email devops@relay2.com dev.relay2.host.
  ```

- create instance
  
  ```bash
  openstack server create \
      --image ubuntu1404 \
      --flavor m1.tiny \
      --user-data ~/kolla/user_data_cn.txt \
      --key-name hzdev \
      --network vlan807 \
      test-01
  ```
