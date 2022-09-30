# isolated testing environment

## Rundeck

  ```text
  http://192.168.20.13:4440   (ldap authentication)
  ```

## physical host

  ```text
  ext: 192.168.20.13
  int: 10.99.0.5
  ```

## vm
  | Hostname            | IP address  |
  | ------------------- | ----------- |
  | devops (ntp server) | 10.99.0.51  |
  | mysql-01            | 10.99.0.100 |
  | srv-01              | 10.99.0.101 |
  | dsas-01             | 10.99.0.102 |
  | mgmt-01             | 10.99.0.103 |
  | scm-01              | 10.99.0.104 |
  | server-01           | 10.99.0.105 |
  | tm-01               | 10.99.0.106 |
  | cwlc-01             | 10.99.0.107 |

## AP

| mac address       | IP address | model | how to login                                  |
| ----------------- | ---------- | ----- | --------------------------------------------- |
| B4:82:C5:00:30:CC | 10.99.0.50 | RA200 | sudo minicom (on 192.168.20.13)               |
| B4:82:C5:00:57:2A | 10.99.0.52 | RA320 | ssh -p 23 root@10.99.0.52  (on 192.168.20.13) |
| B4:82:C5:00:59:94 | 10.99.0.53 | RA340 | ssh -p 23 root@10.99.0.53  (on 192.168.20.13) |

## switch 192.168.20.252

  ```text
  !
  interface GigabitEthernet0/35
   description orbit13-eth1
   switchport trunk encapsulation dot1q
   switchport trunk allowed vlan 99
   switchport mode trunk
  
  !
  interface GigabitEthernet0/38
   description to-netgear-switch
   switchport access vlan 99
   switchport trunk encapsulation dot1q
   switchport trunk allowed vlan 20
   switchport mode access
  
  !
  interface GigabitEthernet0/40
   description cisco-24-02
   switchport trunk encapsulation dot1q
   switchport trunk allowed vlan 30,99
   switchport mode trunk
  ```

## switch 172.16.101.1
  ```text
  !
  interface GigabitEthernet0/2
   switchport trunk encapsulation dot1q
   switchport trunk allowed vlan 30,99
   switchport mode trunk
  
  !
  interface GigabitEthernet0/24
   switchport trunk encapsulation dot1q
   switchport trunk allowed vlan 30,99,101-120
   switchport mode trunk
  ```

## switch 172.16.101.2
  ```text
  !
  interface GigabitEthernet0/47
   switchport trunk encapsulation dot1q
   switchport trunk allowed vlan 30,99,101-120
   switchport mode trunk
   power inline port 2x-mode
   power inline never
  
  !
  interface GigabitEthernet0/30
   switchport trunk encapsulation dot1q
   switchport trunk native vlan 99
   switchport trunk allowed vlan 30,99,101-120
   switchport mode trunk
   power inline port 2x-mode
  
  !
  interface GigabitEthernet0/34
   switchport trunk encapsulation dot1q
   switchport trunk native vlan 99
   switchport trunk allowed vlan 30,99,101-120
   switchport mode trunk
   power inline port 2x-mode
  ```
