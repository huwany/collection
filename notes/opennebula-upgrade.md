## Upgrade from 6.x to 6.2

* Download debian packages from  <https://downloads.opennebula.io/packages>, and add to local aptly server

* Check Virtual Machine Status

  ```txt
  Before proceeding, make sure you don’t have any VMs in a transient state (prolog, migrate, epilog, save). 
  Wait until these VMs get to a final state (running, suspended, stopped, done).
  ```

* Set All nodes to Disable Mode

  ```bash
  for i in `onehost list -l name --no-header`;do sudo -u oneadmin onehost disable $i;done
  ```

* Stop OpenNebula

  ```bash
  sudo systemctl stop \
  	opennebula-flow.service \
  	opennebula-gate.service \
  	opennebula-hem.service \
  	opennebula-novnc.service \
  	opennebula-scheduler.service \
  	opennebula-ssh-agent.service \
  	opennebula-sunstone.service \
  	opennebula-showback.timer \
  	opennebula-ssh-socks-cleaner.timer \
  	opennebula.service
  ```

* Make sure that every OpenNebula process is stopped. the output of the following command should be empty

  ```bash
  systemctl list-units | grep opennebula
  ```

* Back-up OpenNebula Configuration

  ```bash
  sudo rsync -avr /etc/one/ /etc/one.$(date +'%Y-%m-%d')/
  sudo rsync -avr /var/lib/one/remotes/etc/ /var/lib/one/remotes/etc.$(date +'%Y-%m-%d')/
  sudo -u oneadmin onedb backup
  ```

* Upgrade admin node to the New Version

  ```bash
  sudo apt-get update
  sudo apt-get install --only-upgrade -y \
  	opennebula \
  	opennebula-sunstone \
  	opennebula-gate \
  	opennebula-flow \
  	opennebula-provision \
  	python3-pyone
  ```
  
* Upgrade the Database Version

  ```bash
  sudo -u oneadmin onedb upgrade -v
  ```

* Check DB Consistency

  ```bash
  onedb fsck
  MySQL dump stored in /var/lib/one/mysql_localhost_opennebula.sql
  Use 'onedb restore' or restore the DB using the mysql command:
  mysql -u user -h server -P port db_name < backup_file
  
  Total errors found: 0
  ```

* Start OpenNebula

  ```bash
  sudo systemctl start \
  	opennebula.service \
  	opennebula-sunstone.service \
  	opennebula-flow.service \
  	opennebula-gate.service \
  	opennebula-hem.service \
  	opennebula-novnc.service \
  	opennebula-scheduler.service \
  	opennebula-ssh-agent.service \
  	opennebula-ssh-socks-cleaner.timer
  ```

* Update the Hypervisors

  ```bash
  sudo -u oneadmin onehost sync
  ```

* Upgrade the kvm node to the New Version

  ```bash
  sudo apt-get update
  sudo apt-get install --only-upgrade -y opennebula-node-kvm
  ```
  
* Set All nodes to Enable Mode

  ```bash
  for i in `onehost list -l name --no-header`;do sudo -u oneadmin onehost enable $i;done
  ```

* Verify