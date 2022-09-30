# How to migrate nextcloud

## switch to maintenance

- Package installation

  ```bash
  sudo -u www-data php occ maintenance:mode --on
  ```

- Docker installation

  ```bash
  docker exec -it -u www-data nextcloud_app_1 php occ maintenance:mode --on
  ```

## backup

- Backup folders

  ```bash
  rsync -Aavx nextcloud/ nextcloud-dirbkp_`date +"%Y%m%d"`/
  ```

- Backup DB

  ```bash
  mysqldump --single-transaction -h [server] -u [username] -p[password] [db_name] > nextcloud-sqlbkp_`date +"%Y%m%d"`.bak
  ```

## Restore

- Restore folders

  ```bash
  rsync -Aax nextcloud-dirbkp/ nextcloud/
  ```
  
- Recreate database

  ```bash
  mysql -hlocalhost -uroot -pmysql -e "DROP DATABASE nextcloud"
  mysql -hlocalhost -uroot -pmysql -e "CREATE DATABASE nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci"
  ```

- Restore database

  ```bash
  mysql -h db -uroot -pmysql nextcloud < nextcloud-sqlbkp.bak
  ```

 ## Disable maintenance mode

 - Package installation

   ```bash
   sudo -u www-data php occ maintenance:mode --off
   ```

 - Docker installation

   ```bash
   docker exec -it -u www-data nextcloud_app_1 php occ maintenance:mode --off
   ```