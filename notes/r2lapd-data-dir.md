# how to change r2ldap data dir

1. install r2ldap

   ```
   sudo apt-get install -y r2config=1.9.0-20200804
   sudo apt-get install -y r2ldap=1.9.0-20200804
   ```

2. prepare data dir

   ```bash
   sudo mkdir -p /data/ldap
   sudo rsync -avr /etc/ldap/slapd.d /data/
   sudo chown -R openldap:openldap /data/slapd.d /data/ldap
   ```

3. config apparmor

   ```bash
   sudo vi /etc/apparmor.d/usr.sbin.slapd
   
   # add following lines 
     /data/ldap/ r,
     /data/ldap/** rwk,
     /data/** kr,
     /data/slapd.d/** rwk,
   ```

4. Restart apparmor service

   ```bash
   sudo service apparmor restart
   ```

5. config slapd default env

   ```bash
   sudo vi /etc/default/slapd
   
   # add the following line
   SLAPD_CONF="/data/slapd.d"
   ```

6. config slapd directory in database

   ```bash
   cat << EOF | sudo tee /tmp/update_olcDbDirectory.txt
   dn: olcDatabase={1}hdb,cn=config
   changetype: modify
   replace: olcDbDirectory
   olcDbDirectory: /data/ldap
   EOF
   ```

7. stop slapd service

   ```bash
   sudo service slapd stop
   ```

8. update slapd entry

   ```bash
   ldapmodify -Q -Y EXTERNAL -H ldapi:/// -f /tmp/update_olcDbDirectory.txt
   ```

9. verify config

   ```bash
   ldapsearch -Y EXTERNAL -H ldapi:/// -b cn=config
   ```

10. restore slapd

    ```bash
    cd /opt/relay2/ldap/
    ./slapd.sh restore 20200804
    ```

