# How to trim database in Data Center

## disables apt auto upgrade

* disable apt auto upgrade
  
  ```bash
  cat << EOF | sudo tee /etc/apt/apt.conf.d/20auto-upgrades
  APT::Periodic::Update-Package-Lists "0";
  APT::Periodic::Download-Upgradeable-Packages "0";
  APT::Periodic::AutocleanInterval "0";
  APT::Periodic::Unattended-Upgrade "1";
  EOF
  ```

## Trim History Data

* Run below SQL to check the partitions.
  
  ```sql
  SELECT TABLE_NAME, PARTITION_NAME, PARTITION_ORDINAL_POSITION, TABLE_ROWS
  FROM information_schema.PARTITIONS 
  WHERE TABLE_SCHEMA = 'r2db' AND TABLE_NAME = 'ApHealth';
  
  SELECT TABLE_NAME, PARTITION_NAME, PARTITION_ORDINAL_POSITION, TABLE_ROWS
  FROM information_schema.PARTITIONS 
  WHERE TABLE_SCHEMA = 'r2db' AND TABLE_NAME = 'ClientStation';
  
  SELECT TABLE_NAME, PARTITION_NAME, PARTITION_ORDINAL_POSITION, TABLE_ROWS
  FROM information_schema.PARTITIONS 
  WHERE TABLE_SCHEMA = 'r2db' AND TABLE_NAME = 'CsApStats';
  
  SELECT TABLE_NAME, PARTITION_NAME, PARTITION_ORDINAL_POSITION, TABLE_ROWS
  FROM information_schema.PARTITIONS 
  WHERE TABLE_SCHEMA = 'r2db' AND TABLE_NAME = 'CsBssidStats';
  ```

* drop those partitions and only leave last ONE partitions (only leave p_max) by using below SQL.
  
  ```sql
  ALTER TABLE ApHealth DROP PARTITION p_201810;
  ALTER TABLE ApHealth DROP PARTITION p_201811;
  ALTER TABLE ApHealth DROP PARTITION p_201812;
  ```
  
  ```sql
  ALTER TABLE ClientStation DROP PARTITION p_201810;
  ALTER TABLE ClientStation DROP PARTITION p_201811;
  ALTER TABLE ClientStation DROP PARTITION p_201812;
  ```
  
  ```sql
  ALTER TABLE CsApStats DROP PARTITION p_201810;
  ALTER TABLE CsApStats DROP PARTITION p_201811;
  ALTER TABLE CsApStats DROP PARTITION p_201812;
  ```
  
  ```sql
  ALTER TABLE CsBssidStats DROP PARTITION p_201810;
  ALTER TABLE CsBssidStats DROP PARTITION p_201811;
  ALTER TABLE CsBssidStats DROP PARTITION p_201812;
  ```

* After those paritions been dropped, run below store procedure to trim the data older than 2019-07-01. This will take times (maybe whole day), so please use VNC connection. 
  
  ```sql
  CALL TrimOldData(UNIX_TIMESTAMP('2021-05-01 00:00:00')*1000, 50000);
  ```

* Once it’s done, please purge mysql log to trim the size of database further.Run below SQL to delete log and only leave last 2 log files…. Each mysql-bin.xxxxx file is around 1GB. So don’t leave too much log files there.
  
  ```sql
  Show binary logs;
  Purge binary logs to 'mysql-bin.xxxxxx';
  ```

## Optimize Tables

* find big tables
  
  ```sql
  SELECT CONCAT(table_schema, '.', table_name),
         CONCAT(ROUND(table_rows / 1000000, 2), 'M')                                    rows,
         CONCAT(ROUND(data_length / ( 1024 * 1024 * 1024 ), 2), 'G')                    DATA,
         CONCAT(ROUND(index_length / ( 1024 * 1024 * 1024 ), 2), 'G')                   idx,
         CONCAT(ROUND(( data_length + index_length ) / ( 1024 * 1024 * 1024 ), 2), 'G') total_size,
         ROUND(index_length / data_length, 2)                                           idxfrac
  FROM   information_schema.TABLES
  ORDER  BY data_length + index_length DESC
  LIMIT  10;
  ```

* optimize a table
  
  ```sql
  OPTIMIZE TABLE ApHealth;
  OPTIMIZE TABLE ClientStation;
  OPTIMIZE TABLE CsBssidStats;
  OPTIMIZE TABLE CsApStats;
  OPTIMIZE TABLE ApHealthStatsBy10Min;
  ```