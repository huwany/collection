## installation

* prepare enviroment
  
  ```bash
  sudo apt update
  sudo apt install -y python3-pip httpie jq
  ```

* config pipy index (China only)
  
  ```bash
  mkdir ~/.pip
  cat << EOF > ~/.pip/pip.conf
  [global]
  index-url = https://mirrors.aliyun.com/pypi/simple/
  
  [install]
  trusted-host=mirrors.aliyun.com
  EOF
  ```

* install packages
  
  ```bash
  sudo python3 -m pip install -U pip
  sudo python3 -m pip install -r requirements.txt
  ```

* get the ansible recipes
  
  ```bash
  ansible-galaxy collection install pulp.pulp_installer
  ansible-galaxy install geerlingguy.postgresql
  ```

* deploy pulp 3
  
  ```bash
  ansible-playbook -i hosts install.yaml
  ```

* reset admin password
  
  ```bash
  sudo pulpcore-manager reset-admin-password --password admin
  ```

* create pulp-cli config file
  
  ```bash
  pulp config create --username admin --password admin --no-verify-ssl --base-url https://localhost
  ```

* verify
  
  ```bash
  http --auth admin:admin --verify no get https://localhost/pulp/api/v3/status/
  ```

## create repostory

* env
  
  ```bash
  export BASE_ADDR=https://localhost
  ```

* create repo
  
  ```bash
  http --auth admin:admin --verify no post https://localhost/pulp/api/v3/repositories/deb/apt/ name="relay2"
  ```

* Create a Publication
  
  ```bash
  http --auth admin:admin --verify no get $BASE_ADDR/pulp/api/v3/repositories/deb/apt/
  
  PULP_HREF=`http --auth admin:admin --verify no get $BASE_ADDR/pulp/api/v3/repositories/deb/apt/ | jq .results[0].pulp_href`
  
  http --auth admin:admin --verify no post $BASE_ADDR/pulp/api/v3/publications/deb/apt/ repository=${PULP_HREF} simple=true
  
  http --auth admin:admin --verify no get $BASE_ADDR/pulp/api/v3/tasks/ecdf8112-fc54-49a5-aa05-2d128db6f0db/
  ```

* Create a Distribution
  
  ```bash
  TASKS=`http --auth admin:admin --verify no get $BASE_ADDR/pulp/api/v3/tasks/ | jq .results[0].created_resources[0]`
  ```
