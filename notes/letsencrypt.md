# How to use Letsencrypt

## install

- install Certbot
  
  ```bash
  sudo add-apt-repository ppa:certbot/certbot
  sudo apt update
  sudo apt -y install certbot
  ```

- Requested certificates
  
  ```bash
  certbot certonly \
      -n \
      --text \
      --email wanyong.hu@relay2.com \
      --agree-tos \
      --webroot -w /store/docker/r2orbit/certbot/html -d relay2-us-devops.westus.cloudapp.azure.com
  
  certbot certonly \
      -n \
      --text \
      --email wanyong.hu@relay2.com \
      --agree-tos \
      --webroot -w /store/docker/r2orbit/certbot/html -d relay2-msdn-devops.westus.cloudapp.azure.com
  
  certbot certonly \
      -n \
      --text \
      --email wanyong.hu@relay2.com \
      --agree-tos \
      --webroot -w /store/docker/r2loadbalancer/internal/html -d www.vn.relay2.net
  
  certbot certonly \
      --preferred-challenges dns \
      --agree-tos \
      --manual \
      --server https://acme-v02.api.letsencrypt.org/directory \
      -d *.sp.vn.relay2.net
  
  certbot certonly \
      --preferred-challenges dns \
      --agree-tos \
      --manual \
      --server https://acme-v02.api.letsencrypt.org/directory \
      -d *.mvap.vn.relay2.net
  
  0 3 */7 * * certbot renew --renew-hook "/etc/init.d/nginx reload"
  ```

- cronjob
  
  ```bash
  0 3 */5 * * certbot renew --renew-hook "rsync -ar -e 'ssh -i /root/.ssh/id_rsa' /etc/letsencrypt/ mgmt-01:/etc/letsencrypt/;ssh -i /root/.ssh/id_rsa mgmt-01 -t service apache2 reload"
  ```

## Hangzhou 192.168.20.21

```bash
certbot certonly -d hub.relay2.cn --webroot -w /store/docker/r2ingress/nginx/certbot/ --agree-tos

certbot certonly -d cr.relay2.cn --webroot -w /store/docker/r2ingress/nginx/certbot/ --agree-tos

certbot certonly -d www.relay2.com.cn --webroot -w /store/docker/r2ingress/nginx/certbot/ --agree-tos

certbot certonly -d repo.relay2.cn --webroot -w /store/docker/r2ingress/nginx/certbot/ --agree-tos

certbot certonly -d k8s.relay2.cn --webroot -w /store/docker/r2ingress/nginx/certbot/ --agree-tos

certbot certonly -d git.relay2.cn -m wanyong.hu@relay2.com --webroot -w /store/docker/r2ingress/nginx/certbot/ --agree-tos

certbot certonly -d k8s.demo.relay2.cn -m wanyong.hu@relay2.com --webroot -w /store/docker/r2ingress/nginx/certbot/ --agree-tos

certbot certonly \
  -n \
  --text \
  --email wanyong.hu@relay2.com \
  --agree-tos \
  --webroot -w /store/docker/r2ingress/nginx/certbot -d ds.relay2.cn
```

## cndc 10.51.1.5

* Cert request
  
  ```bash
  certbot certonly -d support.relay2.net.cn --webroot -w /store/docker/r2loadbalancer/certbot/html --agree-tos
  ```

## qa02 192.168.2.214

* cert request
  
  ```bash
  certbot certonly \
    -n \
    --text \
    --email wanyong.hu@relay2.com \
    --agree-tos \
    --webroot -w /store/docker/r2ingress/nginx/certbot -d www.qa02.relay2.net
  ```

* cronjob
  
  ```bash
  sudo -u r2 crontab -e
  0 3 */5 * * sudo certbot renew --renew-hook "sudo rsync -ar -e 'ssh -i /home/r2/.ssh/usdev' /etc/letsencrypt/ r2@mgmt-01:/etc/letsencrypt/;ssh r2@mgmt-01 -t sudo service apache2 reload"
  ```

## qa01 192.168.2.223

* cert request
  
  ```bash
  certbot certonly \
    -n \
    --text \
    --email devops@relay2.com \
    --agree-tos \
    --webroot -w /store/certbot \
    -d www.qa02.relay2.net
  ```

* cronjob
  
  ```bash
  sudo -u r2 crontab -e
  0 3 */5 * * sudo certbot renew --renew-hook "sudo rsync -ar -e 'ssh -i /home/r2/.ssh/usdev' /etc/letsencrypt/ r2@mgmt-01:/opt/relay2/letsencrypt/;ssh r2@mgmt-01 -t sudo service apache2 reload"
  ```
