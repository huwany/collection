# system

* Change Maps.app's language to Chinese.
  
  ```bash
  defaults write com.apple.Maps AppleLanguages '("zh-CN")'
  ```

* Git ssl error
  
  ```bash
  git config --global http.sslVerify false
  ```

* linux as router
  
  ```bash
  echo 1 > /proc/sys/net/ipv4/ip_forward
  iptables -t nat -A POSTROUTING -o brhost -s 10.12.0.0/16 -j MASQUERADE
  ```
- install pipy
  
  ```bash
  sudo apt install -y python3-pip
  ```

- config pip (for China only)
  
  ```bash
  cat << EOF | sudo tee /etc/pip.conf
  [global]
  index-url = https://mirrors.aliyun.com/pypi/simple/
  
  [install]
  trusted-host=mirrors.aliyun.com
  EOF
  ```

- upgrade pip
  
  ```bash
  sudo pip3 install -U pip
  ```

- install docker-compose
  
  ```bash
  sudo pip3 install docker-compose
  ```
  
- remove unused kernel
  
  ```bash
  dpkg -l | grep linux-image | awk '{ print $2 }' | sort -V | sed -n '/'`uname -r`'/q;p' | xargs sudo apt-get -y purge
  ```
  
- show netstat and count
  
  ```bash
  netstat -ant | awk '/^tcp/{print $NF}' | sort | uniq -c| sort -nr
  ```
  
- Recovery initramfs missing
  
  ```bash
  sudo fdisk -l
  sudo mount /dev/sdax /mnt
  sudo mount --bind /dev /mnt/dev
  sudo mount --bind /dev/pts /mnt/dev/pts
  sudo mount --bind /proc /mnt/proc
  sudo mount --bind /sys /mnt/sys
  sudo chroot /mnt 
  
  VERSION=`uname -r`
  
  update-initramfs -u -k $VERSION
  
  update-grub
  
  reboot
  ```
  
- to uninstall all the Python packages
  
  ```bash
  pip uninstall -y -r <(pip freeze)
  ```
  
  

# create read only mysql user

- create user
  
  ```mysql
  GRANT SElECT ON *.* TO 'dev'@'rssh-01.internal.cloudapp.net'  IDENTIFIED BY "r2dev2020";
  ```

# git

- remove file/directory
  
  ```bash
  git rm -r -n --cached file/directory
  
  git rm -r --cached file/directory
  
  git commit -m "drop file/directory"
  
  git push origin master
  ```

- setup proxy
  ```bash
  git config --global http.proxy 'http://127.0.0.1:7890' 
  git config --global https.proxy 'http://127.0.0.1:7890'
  
  git config --global --get http.proxy
  git config --global --get https.proxy
  
  git config --global --unset http.proxy
  git config --global --unset https.proxy
  ```

# docker

- config env for China only
  
  ```bash
  cat <<EOF | sudo tee /etc/apt/sources.list.d/docker-ce.list
  deb [arch=amd64] https://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable
  EOF
  
  curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo apt-key add -
  
  sudo mkdir /etc/docker/
  sudo tee /etc/docker/daemon.json <<-'EOF'
  {
    "registry-mirrors": [
      "https://registry.docker-cn.com",
      "https://hub-mirror.c.163.com",
      "https://ee9kcv09.mirror.aliyuncs.com"
    ],
    "bip": "",
    "default-address-pools": [
      {
        "base": "10.252.0.0/16",
        "size": 24
      }
    ],
    "features": {
      "buildkit": true
    }
  }
  EOF
  ```
  
- config env for global
  
  ```
  cat <<EOF | sudo tee /etc/apt/sources.list.d/docker-ce.list
  deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable
  EOF
  
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  ```
  
- install docker
  
  ```bash
  sudo apt update && sudo apt install -y docker-ce && sudo usermod -aG docker r2 && newgrp docker
  ```
  
- restart docker if needed
  
  ```
  sudo systemctl daemon-reload
  sudo systemctl restart docker
  ```
  
- registry
  
  ```bash
  sudo mkdir -p /store/registry
  sudo docker run -d -p 5000:5000 \
      --restart=always \
      --name registry \
      -v /store/registry:/var/lib/registry \
      registry:2
  ```
  
- K8S env
  
  ```bash
  sudo apt-get update
  sudo apt-get install -y apt-transport-https
  
  curl https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | sudo apt-key add -
  
  cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
  deb https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main
  EOF
  
  sudo apt-get update
  sudo apt-get install -y kubectl
  
  source <(kubectl completion bash)
  kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl > /dev/null
  ```
  
- helm
  
  ```bash
  curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
  
  cat <<EOF | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
  deb https://baltocdn.com/helm/stable/debian/ all main
  EOF
  
  sudo apt-get update
  sudo apt-get install -y helm
  
  source <(helm completion bash)
  helm completion bash | sudo tee /etc/bash_completion.d/helm > /dev/null
  ```
  
- add helm repo
  - for non-China:
    ```bash
    helm repo add stable https://charts.helm.sh/stable
    ```
  - for China:
    ```bash
    helm repo add stable https://mirror.azure.cn/kubernetes/charts
    ```

## disable auto upgrade on ubuntu

* config  auto upgrades
  
  ```bash
  cat << EOF | sudo tee /etc/apt/apt.conf.d/20auto-upgrades /etc/apt/apt.conf.d/10periodic
  APT::Periodic::Update-Package-Lists "5";
  APT::Periodic::Download-Upgradeable-Packages "0";
  APT::Periodic::AutocleanInterval "0";
  APT::Periodic::Unattended-Upgrade "0";
  EOF
  
  sudo systemctl stop apt-daily.service
  sudo systemctl stop apt-daily.timer
  sudo systemctl stop apt-daily-upgrade.service
  sudo systemctl stop apt-daily-upgrade.timer
  sudo systemctl disable apt-daily.service
  sudo systemctl disable apt-daily.timer
  sudo systemctl disable apt-daily-upgrade.service
  sudo systemctl disable apt-daily-upgrade.timer
  sudo systemctl daemon-reload
  ```

## increase open files limit

* add limit file
  
  ```bash
  cat << EOF | sudo tee /etc/security/limits.d/r2limits.conf
  # /etc/security/limits.d/r2limits.conf
  #
  # !!!
  * soft nofile 65536
  * hard nofile 65536
  
  # End of file
  EOF
  ```

## cleanup opennbula

- clean up opennebula
  
  ```bash
  dpkg -l |grep -E 'opennebula|libvirt|kvm|qemu' |awk '{print $2}'|xargs sudo apt purge -y
  userdel -f oneadmin
  find / -type d -name one -exec rm -rf {} \;
  find / ! -path '/var/lib/docker/*' -type d -name libvirt -exec rm -rf {} \;
  ```

### mysql

* add recovery mode
  
  ```bash
  mode=1; sed -i "/^\[mysqld\]/{N;s/$/\ninnodb_force_recovery=$mode/}" /etc/mysql/my.cnf
  ```

* remove recovery mode
  
  ```bash
  sed -i '/innodb_force_recovery/d' /etc/mysql/my.cnf
  ```

## create user

```bash
export NEW_USER="olivia"

export KEY_FILE="/home/${NEW_USER}/.ssh/${NEW_USER}"
export KEY_AUTH="/home/${NEW_USER}/.ssh/authorized_keys"

if ! id -u "${NEW_USER}" >/dev/null 2>&1;then sudo useradd -U -m -s /bin/bash ${NEW_USER};fi

sudo -u ${NEW_USER} ssh-keygen -b 2048 -t rsa -f ${KEY_FILE} -q -N ""
sudo -u ${NEW_USER} echo -n command='"" ' | sudo -u ${NEW_USER} tee ${KEY_AUTH}
sudo -u ${NEW_USER} cat ${KEY_FILE}.pub | sudo -u ${NEW_USER} tee -a ${KEY_AUTH}

sudo -u ${NEW_USER} chmod 600 ${KEY_AUTH}
```

## opennebula

* create disk snapshot

  ```bash
  for i in {32..40};do onevm disk-snapshot-create $i 0 origin;done
  ```

* revert disk snapshot

  ```bash
  for i in {32..40};do onevm disk-snapshot-revert $i 0 origin;done
  ```


## alpine

* change mirror

  ```bash
  sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories
  ```

  
