# how to deploy nomad single node

---

## set up environments

```bash
export REGION=cn
export DATACENTER=dc
export REPO_SERVER=devops
export NOMAD_VERSION=1.2.5
export CONSUL_VERSION=1.11.2

export REGION=jp
export DATACENTER=jpbb
export REPO_SERVER=releases.hashicorp.com
export NOMAD_VERSION=1.3.3
export CONSUL_VERSION=1.13.0

sudo apt update
sudo apt install -y unzip
```

## create consul config file

```bash
sudo mkdir -p /opt/relay2/consul/{conf,data,logs} 

sudo chown -R r2:r2 /opt/relay2/consul/{conf,data,logs} 

cat << EOF | tee /opt/relay2/consul/conf/default.hcl
datacenter           = "${REGION}${DATACENTER}"
data_dir             = "/opt/relay2/consul/data/"
log_file             = "/opt/relay2/consul/logs/consul.log"
log_level            = "INFO"
log_rotate_duration  = "24h"
disable_update_check = true

client_addr          = "0.0.0.0"

performance {
  raft_multiplier = 3
}

limits {
  http_max_conns_per_client = 400
}

enable_local_script_checks = true
EOF

cat << EOF | tee /opt/relay2/consul/conf/server.hcl
server = true
ui = true
bootstrap_expect = 1
EOF
```

## create consul service config file

```bash
cat << EOF | sudo tee /etc/systemd/system/consul.service
[Unit]
Description=Consul
Documentation=https://www.consul.io/
Requires=network-online.target
After=network-online.target

[Service]
Type=notify
User=r2
Group=r2
ExecStart=/usr/local/bin/consul agent \
    -bind="{{GetPrivateIP}}" \
    -retry-join="{{GetPrivateIP}}" \
    -config-dir=/opt/relay2/consul/conf
ExecReload=/bin/kill --signal HUP $MAINPID
KillMode=process
KillSignal=SIGTERM
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF
```

## get consul binary file

```bash
curl -sSL -o /tmp/consul.zip \
    http://${REPO_SERVER}/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip

sudo unzip -o /tmp/consul.zip "consul" -d /usr/local/bin/

sudo chmod +x /usr/local/bin/consul
```

## create nomad config file

```bash
sudo mkdir -p /opt/relay2/nomad/{conf,data,logs}

sudo chown -R r2:r2 /opt/relay2/nomad/{conf,data,logs} 

cat << EOF | tee /opt/relay2/nomad/conf/default.hcl
region               = "${REGION}"
datacenter           = "${DATACENTER}"
data_dir             = "/opt/relay2/nomad/data/"
log_file             = "/opt/relay2/nomad/logs/nomad.log"
log_level            = "INFO"
log_rotate_duration  = "24h"
disable_update_check = true

bind_addr = "0.0.0.0"

acl {
  enabled = false
}

consul {
  address = "127.0.0.1:8500"
  server_service_name = "nomad_server"
  client_service_name = "nomad_client"
  auto_advertise = true
  server_auto_join = true
  client_auto_join = true
}
EOF

cat << EOF | tee /opt/relay2/nomad/conf/server.hcl
server {
  enabled = true
  bootstrap_expect = 1
}
EOF

cat << EOF | tee /opt/relay2/nomad/conf/client.hcl
client {
  enabled = true
  meta = {
    consul = true
    nomad = true
    rabbitmq = true
    redis = true
  }
}

plugin "docker" {
  config {
    allow_privileged = false
    gc {
      image       = false
      container   = true
    }
    volumes {
      enabled = true
    }
  }
}

plugin "raw_exec" {
  config {
    enabled = true
  }
}
EOF
```

## create nomad service config file

```bash
cat << EOF | sudo tee /etc/systemd/system/nomad.service
[Unit]
Description=Nomad
Documentation=https://www.nomadproject.io/docs
Wants=network-online.target
After=network-online.target
Wants=consul.service
After=consul.service

[Service]
User=r2
Group=r2
ExecReload=/bin/kill -HUP $MAINPID
ExecStart=/usr/local/bin/nomad agent -config=/opt/relay2/nomad/conf
KillMode=process
KillSignal=SIGINT
LimitNOFILE=65536
LimitNPROC=infinity
Restart=on-failure
RestartSec=2
TasksMax=infinity
OOMScoreAdjust=-1000

[Install]
WantedBy=multi-user.target
EOF
```

## get nomad binary file

```bash
curl -sSL -o /tmp/nomad.zip \
    http://${REPO_SERVER}/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip

sudo unzip -o /tmp/nomad.zip "nomad" -d /usr/local/bin/

sudo chmod +x /usr/local/bin/nomad
```

## apply systemd config and start service

```bash
sudo systemctl daemon-reload
sudo systemctl enable consul.service nomad.service 
sudo systemctl start consul.service nomad.service
```

## clean up

```bash
sudo systemctl stop consul.service nomad.service
sudo rm -rf \
	/opt/relay2/consul \
	/opt/relay2/nomad \
	/etc/systemd/system/consul.service \
	/etc/systemd/system/nomad.service \
	/usr/local/bin/consul \
	/usr/local/bin/nomad

sudo systemctl daemon-reload
sudo systemctl reset-failed
```

