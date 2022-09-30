## k3d

* get the k3d binary

  ```bash
  sudo curl -sfL http://repo.cn.relay2.host/k3d/v5.3.0/k3d-linux-amd64 -o /usr/local/bin/k3d
  sudo chmod +x /usr/local/bin/k3d
  k3d completion bash | sudo tee /etc/bash_completion.d/k3d
  
  source <(k3d completion bash)
  ```

* create cluster

  ```bash
  k3d cluster create dev \
      --api-port "$(hostname -I | awk '{print $1}'):6443" \
      --port "80:80@loadbalancer" \
      --port "443:443@loadbalancer" \
      --registry-config "/etc/rancher/k3s/registries.yaml"
  ```
  
  