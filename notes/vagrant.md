# how to use vagrant

## install

* http://repo.cnhz.relay2.host/vagrant/2.2.17/vagrant_2.2.17_linux_amd64.zip

## config

* install dependencies

  ```bash
  sudo apt install -y ruby-dev ruby-libvirt libarchive-tools
  ```

* install plugin

  ```bash
  gem source -r https://rubygems.org/
  gem source -a https://gems.ruby-china.com/
  vagrant plugin install vagrant-libvirt --plugin-clean-sources --plugin-source https://gems.ruby-china.com
  vagrant plugin list
  ```

* add ubuntu 20.04 box

  ```
  vagrant box add ubuntu2004 /store/repo/images/uec/focal-server-cloudimg-amd64-vagrant.box --provider=libvirt
  ```

* init config

  ```bash
  vagrant init ubuntu2004
  ```

* up

  ```bash
  vagrant up
  ```

  