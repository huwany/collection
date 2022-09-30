# how to install ceph 15 or higher

1. get the cephadm
   
   ```bash
   curl --silent --remote-name --location https://github.com/ceph/ceph/raw/octopus/src/cephadm/cephadm
   chmod +x cephadm
   sudo mv cephadm /usr/local/sbin/
   ```

2. bootstrap
   
   ```bash
   mkdir -p /etc/ceph
   
   cephadm bootstrap \
     --mon-ip 10.20.20.21 \
     --ssh-private-key /root/.ssh/id_rsa \
     --ssh-public-key /root/.ssh/id_rsa.pub \
     --output-dir /etc/ceph \
     --initial-dashboard-user admin \
     --initial-dashboard-password relay2 \
     --allow-overwrite
   ```

3. distribute ssh key
   
   ```bash
   ssh-copy-id -f -i /etc/ceph/ceph.pub root@hz-node21
   ssh-copy-id -f -i /etc/ceph/ceph.pub root@hz-node22
   ssh-copy-id -f -i /etc/ceph/ceph.pub root@hz-node23
   ssh-copy-id -f -i /etc/ceph/ceph.pub root@hz-node31
   ssh-copy-id -f -i /etc/ceph/ceph.pub root@hz-node32
   ssh-copy-id -f -i /etc/ceph/ceph.pub root@hz-node33
   ```

4. install ceph-common
   
   ```bash
   wget -q -O- 'https://mirrors.aliyun.com/ceph/keys/release.asc' | sudo apt-key add -
   
   echo deb https://mirrors.aliyun.com/ceph/debian-octopus/ $(lsb_release -sc) main | sudo tee /etc/apt/sources.list.d/ceph.list
   apt update
   
   cephadm install ceph-common
   ```

5. config ceph
   
   ```bash
   ceph config set mon public_network 10.20.20.0/24
   ceph config set global cluster_network 10.20.254.0/24
   ceph config set global rbd_default_format 2
   ceph config set global rbd_default_features 3
   ceph config set osd cluster_network 10.20.254.0/24
   ceph config set mon mon_allow_pool_delete true
   ```

6. add host
   
   ```bash
   ceph orch host add hz-node22
   ceph orch host add hz-node23
   ceph orch host add hz-node31
   ceph orch host add hz-node32
   ceph orch host add hz-node33
   ```

7. reconfig
   
   ```bash
   ceph orch daemon reconfig mon.hz-node21
   ceph orch daemon reconfig mon.hz-node22
   ceph orch daemon reconfig mon.hz-node23
   
   ceph orch daemon reconfig osd.0
   ceph orch daemon reconfig osd.1
   ceph orch daemon reconfig osd.2
   ceph orch daemon reconfig osd.3
   ceph orch daemon reconfig osd.4
   ceph orch daemon reconfig osd.5
   ceph orch daemon reconfig osd.6
   ceph orch daemon reconfig osd.7
   ceph orch daemon reconfig osd.8
   ceph orch daemon reconfig osd.9
   ceph orch daemon reconfig osd.10
   ceph orch daemon reconfig osd.11
   ```

8. lookup host
   
   ```bash
   ceph orch host ls
   ```

9. label and apply mon host
   
   ```bash
   ceph orch host label add hz-node21 mon
   ceph orch host label add hz-node22 mon
   ceph orch host label add hz-node23 mon
   
   ceph orch apply mon label:mon
   ```

10. add osd
    
    ```bash
    ceph orch daemon add osd hz-node31:/dev/sdb
    ceph orch daemon add osd hz-node31:/dev/sdc
    ceph orch daemon add osd hz-node31:/dev/sdd
    ceph orch daemon add osd hz-node31:/dev/sde
    
    ceph orch daemon add osd hz-node32:/dev/sdb
    ceph orch daemon add osd hz-node32:/dev/sdc
    ceph orch daemon add osd hz-node32:/dev/sdd
    ceph orch daemon add osd hz-node32:/dev/sde
    
    ceph orch daemon add osd hz-node33:/dev/sdb
    ceph orch daemon add osd hz-node33:/dev/sdc
    ceph orch daemon add osd hz-node33:/dev/sdd
    ceph orch daemon add osd hz-node33:/dev/sde
    ```

11. verify ceph status
    
    ```bash
    ceph -s
      cluster:
        id:     c87472de-f0f8-11ea-b16e-9b15e82d4f22
        health: HEALTH_OK
    
      services:
        mon: 3 daemons, quorum hz-node21,hz-node22,hz-node23 (age 6d)
        mgr: hz-node21.qmtuiw(active, since 6d)
        osd: 12 osds: 12 up (since 10d), 12 in (since 10d)
    
      data:
        pools:   2 pools, 33 pgs
        objects: 20.66k objects, 78 GiB
        usage:   242 GiB used, 11 TiB / 11 TiB avail
        pgs:     33 active+clean
    
      io:
        client:   0 B/s rd, 39 KiB/s wr, 4 op/s rd, 4 op/s wr
    ```

## uninstall

- remove dm
  
  ```bash
  dmsetup status |grep ceph |awk -F: '{print $1}'|xargs dmsetup remove
  ```

- wipe device
  
  ```bash
  wipefs -a /dev/sdb /dev/sdc /dev/sdd /dev/sde
  ```