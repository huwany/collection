# sever

<!-- TOC -->

- [sever](#sever)
  - [install wireguard](#install-wireguard)
    - [common platform](#common-platform)
    - [Azure](#azure)
  - [config wireguard](#config-wireguard)
    - [create keys](#create-keys)
    - [turn on ip forward](#turn-on-ip-forward)
    - [create service config](#create-service-config)
    - [create client config](#create-client-config)
  - [manage service](#manage-service)
    - [start WireGuard](#start-wireguard)
    - [stop WireGuard](#stop-wireguard)
    - [enbale service on startup](#enbale-service-on-startup)
    - [show WireGuard status](#show-wireguard-status)
  - [multiple user](#multiple-user)
    - [stop service](#stop-service)
    - [generate keys](#generate-keys)
    - [add server config](#add-server-config)
    - [create user1 config](#create-user1-config)
    - [start servuce](#start-servuce)

<!-- /TOC -->

## install wireguard

### common platform

```bash
sudo add-apt-repository ppa:wireguard/wireguard
sudo apt update
sudo apt install wireguard resolvconf -y
```

### Azure

```bash
sudo apt install dkms
curl -L -o wireguard-tools.deb https://launchpad.net/~wireguard/+archive/ubuntu/wireguard/+build/19291633/+files/wireguard-tools_1.0.20200510-1~18.04_amd64.deb
curl -L -o wireguard-dkms.deb https://launchpad.net/~wireguard/+archive/ubuntu/wireguard/+build/19258545/+files/wireguard-dkms_1.0.20200429-2~18.04_all.deb
sudo dpkg -i wireguard-tools.deb
sudo dpkg -i wireguard-dkms.deb
sudo modprobe wireguard
```

## config wireguard

### create keys

```bash
cd /etc/wireguard
wg genkey | tee server_privatekey | wg pubkey > server_publickey
wg genkey | tee wanyong_privatekey | wg pubkey > wanyong_publickey
```

### turn on ip forward

```bash
sudo echo 1 > /proc/sys/net/ipv4/ip_forward
sudo sed -i -e  '/^#net.ipv4.ip_forward/s/#//g' /etc/sysctl.conf
sudo sysctl -p
```

### create service config

```bash
cat << EOF | sudo tee /etc/wireguard/wg0.conf
[Interface]
    PrivateKey = $(cat server_privatekey)
    Address = 10.8.51.1/24
    PostUp   = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -A FORWARD -o wg0 -j ACCEPT;iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
    PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -D FORWARD -o wg0 -j ACCEPT;iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
    ListenPort = 444
    #DNS = 223.5.5.5
    MTU = 1420

[Peer]
    PublicKey = $(cat wanyong_publickey)
    AllowedIPs = 10.8.51.2/32
EOF
```

### create client config

```bash
cat << EOF | sudo tee /etc/wireguard/wanyong.conf
[Interface]
PrivateKey = $(cat wanyong_privatekey)
Address = 10.8.51.2/24
# local or remote dns
#DNS = 223.5.5.5
MTU = 1420

[Peer]
PublicKey = $(cat server_publickey)
Endpoint = 40.73.27.183:444
# C class network
#AllowedIPs = 0.0.0.0/0, ::0/0
PersistentKeepalive = 25
EOF
```

## manage service

### start WireGuard

```bash
wg-quick up wg0
```

### stop WireGuard

```bash
wg-quick down wg0
```

### enbale service on startup

```bash
systemctl enable wg-quick@wg0
```

### show WireGuard status

```bash
wg
```

## multiple user

### stop service

```bash
wg-quick down wg0
```

### generate keys

```bash
wg genkey | tee user1_privatekey | wg pubkey > user1_publickey
```

### add server config

```bash
cat << EOF | sudo tee -a /etc/wireguard/wg0.conf
[Peer]
PublicKey = $(cat user1_publickey)
AllowedIPs = 10.0.0.3/32
EOF
```

### create user1 config

```bash
cat << EOF | sudo tee -a /etc/wireguard/user1.conf
[Interface]
PrivateKey = $(cat user1_privatekey)
Address = 10.0.0.3/24
# local or remote dns
#DNS = 223.5.5.5
MTU = 1420

[Peer]
PublicKey = $(cat server_publickey)
Endpoint = 1.2.3.4:443
# C class network
#AllowedIPs = 0.0.0.0/0, ::0/0
PersistentKeepalive = 25
EOF
```

### start servuce

```bash
wg-quick up wg0
```
