# how to migrate elasticsearch data

## prepare NFS server

1. install nfs

   ```bash
   sudo apt install -y nfs-kernel-server
   ```

2. Prepare user

   ```bash
   sudo groupadd -g 598 elasticsearch
   sudo useradd -u 644 -g elasticsearch elasticsearch
   ```

3. Prepare directory

   ```bash
   sudo mkdir -p /store/nfs/elasticsearch
   sudo chown -R elasticsearch:elasticsearch /store/nfs/elasticsearch
   ```

4. config nfs server

   ```bash
   sudo vi /etc/exports
   /store/nfs/elasticsearch */24(insecure,rw,no_root_squash,sync)

   sudo systemctl restart nfs-server
   ```

5. check nfs server status

   ```bash
   exportfs  -v
   /store/nfs/elasticsearch *(rw,wdelay,insecure,no_root_squash,no_subtree_check,sec=sys,rw,no_root_squash,no_all_squash)
   ```

## prepare elasticsearch node

0. change uid/gid if elasticsearch not  644/598 (optional)

    ```bash
    cat /etc/passwd |grep ^elasticsearch
    elasticsearch:x:112:117::/home/elasticsearch:/bin/false

    sudo systemctl stop elasticsearch.service

    sudo usermod -u 644 elasticsearch
    sudo groupmod -g 598  elasticsearch

    sudo find / ! -path "/proc/*" -user 112 -exec chown -h elasticsearch {} \;
    sudo find / ! -path "/proc/*" -group 117 -exec chgrp -h elasticsearch {} \;

    sudo systemctl start elasticsearch.service
    ```

1. install nfs client

   ```bash
   sudo apt update
   sudo apt install -y nfs-common
   ```

2. check the mount point

   ```bash
   showmount -e NFS_SERVER_IP
   Export list for NFS_SERVER_IP:
   /store/nfs/elasticsearch */24
   ```

3. config mount point

   ```bash
   sudo mkdir -p /store/nfs/elasticsearch

   sudo chown -R elasticsearch:elasticsearch /store/nfs/elasticsearch

   sudo vi /etc/fstab
   # some system config
   NFS_SERVER_IP:/store/nfs/elasticsearch /store/nfs/elasticsearch nfs defaults 0 0

   sudo sudo mount -a
   ```

4. check nfs client status

   ```bash
   mount -l |grep elasticsearch
   NFS_SERVER_IP:/store/nfs/elasticsearch on /store/nfs/elasticsearch type nfs4(rw,relatime,vers=4.0,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcpport=0,timeo=600,retrans=2,sec=sys,clientaddr=0.0.0.0,local_lock=none,addr=NFS_SERVER_IP)
   ```

5. config elasticsearch node

   ```bash
   sudo vi /etc/elasticsearch/elasticsearch.yml
   # some elasticsearch config
   path.repo: ["/store/nfs/elasticsearch"]
   ```

6. restart and check elasticsearch service

   ```bash
   sudo systemctl restart elasticsearch.service
   sudo systemctl status elasticsearch.service
   ```

7. check elasticsearch cluster status

   ```bash
   curl http://${OLD_ELASTICSEARCH_IP}:9200/_cluster/health
   {"cluster_name":"elastic-jpdc","status":"green","timed_out":false,"number_of_nodes":6,"number_of_data_nodes":3,"active_primary_shards":15,"active_shards":30,"relocating_shards":0,"initializing_shards":0,"unassigned_shards":0,"delayed_unassigned_shards":0,"number_of_pending_tasks":0,"number_of_in_flight_fetch":0,"task_max_waiting_in_queue_millis":0,"active_shards_percent_as_number":100.0}%
   ```

## create snapshot on elasticsearch

0. set Eenvironment

   ```bash
   OLD_ELASTICSEARCH_IP=192.168.xx.xx
   ```

   

1. create backup repo

   ```bash
   curl -XPUT http://${OLD_ELASTICSEARCH_IP}:9200/_snapshot/backup -H 'Content-Type: application/json' -d '
   {
   "type": "fs",
   "settings": {
        "location": "/store/nfs/elasticsearch" ,
        "compress": true
   }
   }'
   ```

2. create snapshot

   ```bash
   curl -XPUT http://${OLD_ELASTICSEARCH_IP}:9200/_snapshot/backup/snapshot_1?wait_for_completion=true
   ```

3. copy elasticsearch archives to the target server

   ```bash
   rsync -avr /store/nfs/elasticsearch NEW_ELASTICSEARCH_IP:
   ```

## restore snapshot on target server

1. config elasticsearch node

   ```bash
   sudo vi /etc/elasticsearch/elasticsearch.yml
   # some elasticsearch config
   path.repo: ["/store/nfs/elasticsearch"]
   ```

2. create backup repo

   ```bash
   curl -XPUT http://${NEW_ELASTICSEARCH_IP}:9200/_snapshot/backup -H 'Content-Type: application/json' -d '
   {
   "type": "fs",
   "settings": {
        "location": "/store/nfs/elasticsearch" ,
        "compress": true
   }
   }'
   ```

4. delete exsiting index

   ```bash
   curl -X DELETE http://${NEW_ELASTICSEARCH_IP}:9200/wu-cache-accum
   curl -X DELETE http://${NEW_ELASTICSEARCH_IP}:9200/wu-cache-aggr
   curl -X DELETE http://${NEW_ELASTICSEARCH_IP}:9200/wu-cache-diagnose
   ```

3. restart and check elasticsearch service

   ```bash
   sudo systemctl restart elasticsearch.service
   sudo systemctl status elasticsearch.service
   ```

4. restore snapstot

   ```bash
   curl -X POST http://${NEW_ELASTICSEARCH_IP}:9200/_snapshot/backup/snapshot_1/_restore?wait_for_completion=true
   ```

4. check

   ```bash
   curl http://${NEW_ELASTICSEARCH_IP}:9200/_cat/indices?v
   ```

