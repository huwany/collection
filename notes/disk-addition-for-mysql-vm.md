# How to increase disk size for qe-mysql-01

> updated by huwany@outlook.com May 20, 2019

## on opennebula one(10.101.0.20)

1. to find the VM id of qe-mysql-01, in this case it's 83.

   ```bash
   r2@one:~$ sudo onevm show qe-mysql-01 | grep ^ID
   ID                  : 83
   ```

2. to power off the vm

   ```bash
   r2@one:~$ sudo onevm poweroff 83
   ```

3. waiting for the state of 83 goes into POWEROFF

   ```bash
   r2@one:~$ sudo onevm show 83 |grep LCM_STATE
   LCM_STATE           : POWEROFF
   ```

4. to attach disk to vm

   ```bash
   r2@one:~$ sudo onevm disk-attach 83 --image 5
   ```

5. to boot up the vm

   ```bash
   r2@one:~$ sudo onevm resume 83
   ```

## on qe-mysql-01

1. to prepare the par tition

   ```bash
   r2@qe-mysql-01:~$  sudo fdisk /dev/sdb
   Command (m for help): n
   Partition type:
      p   primary (0 primary, 0 extended, 4 free)
      e   extended
   Select (default p): p
   Partition number (1-4, default 1):
   First sector (2048-125829119, default 2048):
   Last sector, +sectors or +size{K,M,G} (2048-125829119, default 125829119):
   Using default value 125829119

   Command (m for help):
   The partition table has been altered!

   Calling ioctl() to re-read partition table.
   Syncing disks.
   ```

2. to verify the new partition

   ```bash
   r2@qe-mysql-01:~$ sudo lsblk
   NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
   sda      8:0    0    40G  0 disk
   |-sda1   8:1    0    36G  0 part /
   |-sda2   8:2    0     1K  0 part
   `-sda5   8:5    0     4G  0 part [SWAP]
   sdb      8:16   0    60G  0 disk
   `-sdb1   8:17   0    60G  0 part /data
   sr0     11:0    1   366K  0 rom
   ```

3. format the partition

   ```bash
   r2@qe-mysql-01:~$ sudo mkfs.ext4 /dev/sdb1
   ```

4. to find the uuid for new partition sdb1, it's 849a372d-b9c1-4451-a93b-1fc054fe9b7c

   ```bash
   r2@qe-mysql-01:~$ ls -al /dev/disk/by-uuid/ | grep sdb
   lrwxrwxrwx 1 root root  10 Feb 10 22:03 849a372d-b9c1-4451-a93b-1fc054fe9b7c -> ../../sdb1
   ```

5. create mount point

   ```bash
   r2@qe-mysql-01:~$ sudo mkdir /data
   ```

6. add the following line to /etc/fstab

   ```bash
   r2@qe-mysql-01:~$ sudo vi /etc/fstab
   UUID=849a372d-b9c1-4451-a93b-1fc054fe9b7c /data ext4 defaults 0 1
   ```

7. mount the disk partition

   ```bash
   r2@qe-mysql-01:~$ sudo mount -a
   ```

8. to verify the mount ifo

   ```bash
   r2@qe-mysql-01:~$ sudo mount -l |grep sdb
   /dev/sdb1 on /data type ext4 (rw)
   ```

9. create mysql data dir

    ```bash
    r2@qe-mysql-01:~$ sudo mkdir -p /data/mysql
    r2@qe-mysql-01:~$ sudo chown -R mysql:mysql /data/mysql
    r2@qe-mysql-01:~$ sudo chmod 700 /data/mysql
    ```

10. stop mysql service

    ```bash
    r2@qe-mysql-01:~$ sudo service mysql stop
    ```

11. copy mysql data

    ```bash
    r2@qe-mysql-01:~$ sudo rsync -avrP /var/lib/mysql/ /data/mysql/
    ```

12. edit my.cnf

    ```bash
    r2@qe-mysql-01:~$ sudo vi /etc/mysql/my.cnf
    [mysqld]
    port      = 3306
    datadir   = /data/mysql
    bind-address = 0.0.0.0
    ```

13. update apparmor policy

    ```bash
    r2@qe-mysql-01:~$ sudo sed -i -e 's/\/var\/lib\/mysql\//\/data\/mysql\//g' /etc/apparmor.d/usr.sbin.mysqld
    r2@qe-mysql-01:~$ sudo /etc/init.d/apparmor restart
    ```

14. restart mysql service

    ```bash
    r2@qe-mysql-01:~$ sudo service mysql restart
    ```

15. verify:

    ```bash
    r2@qe-mysql-01:~$ mysql -uroot -p
    mysql> show variables like '%datadir%';
    +---------------+--------------+
    | Variable_name | Value        |
    +---------------+--------------+
    | datadir       | /data/mysql/ |
    +---------------+--------------+
    1 row in set (0.01 sec)

    mysql>
    ```
