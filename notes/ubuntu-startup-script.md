## how to run script on startup


* create script

  ```bash
  sudo mkdir -p /opt/relay2/scripts/
  
  cat << EOF | sudo tee /opt/relay2/scripts/nat.sh
  #!/bin/bash
  NIC=`ip -4 route ls default | awk '{print $5}'`
  sudo sed -i -e '/net.ipv4.ip_forward=1/s/^#//g' /etc/sysctl.conf
  sudo sysctl -p -q
  
  sudo iptables -t nat -F
  sudo iptables -t nat -X
  sudo iptables -t nat -Z
  
  sudo iptables -t nat -A POSTROUTING -o ${NIC} -j MASQUERADE
  
  # one:22
  sudo iptables -t nat -A PREROUTING  -p tcp --dport 22020 -j DNAT --to 10.12.0.20:22
  
  # one:9869
  sudo iptables -t nat -A PREROUTING  -p tcp --dport 19869 -j DNAT --to 10.12.0.20:9869
  EOF
  
  sudo chmod +x /opt/relay2/scripts/nat.sh
  ```

   

* create systemd service file

  ```bash
  cat << EOF | sudo tee /etc/systemd/system/r2cloudbox-nat.service
  [Unit]
  Description=Set up iptables rule for CloudBox
  After=network.service
  
  [Service]
  ExecStart=/opt/relay2/scripts/nat.sh
  
  [Install]
  WantedBy=default.target
  EOF
  
  sudo chmod 664 /etc/systemd/system/r2cloudbox-nat.service
  sudo systemctl daemon-reload
  sudo systemctl enable r2cloudbox-nat.service
  ```

  