## switch env

* Monitoring account

  ```bash
  Subscriptions ID:8073823b-ecf4-4ad9-825f-5736776cf5c6
  Object ID: e5265529-0d1f-4a75-8145-8258b4ea750f
  
  Application (client) ID: b9c40d7d-df04-433c-8122-99157b9c2ed9
  Directory (tenant) ID: 4b44da53-2ad5-404f-9618-b6799a841890
  
  Application (client) Secret: lPgB~e5.n.oNJ_aLoPe.-b3C5ZvnSTL76~
  ```

* Azure Global

  ```bash
  az cloud set -n AzureCloud
  az login -u wanyong.hu@relay2.com -p 
  ```

* Azure China

  ```bash
  az cloud set -n AzureChinaCloud
  az login -u admin@relay2.partner.onmschina.cn -p 
  export SUB_ID=8073823b-ecf4-4ad9-825f-5736776cf5c6
  ```

## monitring

* how to get the metrics

  ```bash
  az monitor metrics list-definitions \
    --output table \
    --resource /subscriptions/${SUB_ID}/resourceGroups/cn-nms-rg/providers/Microsoft.Compute/virtualMachines/cn-cwlc-01-vm
  
  Display Name                    Metric Name                       Unit            Type     Dimension Required    Dimensions
  ------------------------------  --------------------------------  --------------  -------  --------------------  ------------
  Percentage CPU                  Percentage CPU                    Percent         Average  False
  Network In                      Network In                        Bytes           Total    False
  Network Out                     Network Out                       Bytes           Total    False
  Disk Read Bytes                 Disk Read Bytes                   Bytes           Total    False
  Disk Write Bytes                Disk Write Bytes                  Bytes           Total    False
  Disk Read Operations/Sec        Disk Read Operations/Sec          CountPerSecond  Average  False
  Disk Write Operations/Sec       Disk Write Operations/Sec         CountPerSecond  Average  False
  CPU Credits Remaining           CPU Credits Remaining             Count           Average  False
  CPU Credits Consumed            CPU Credits Consumed              Count           Average  False
  Data Disk Read Bytes/Sec        Per Disk Read Bytes/sec           CountPerSecond  Average  False                 SlotId
  Data Disk Write Bytes/Sec       Per Disk Write Bytes/sec          CountPerSecond  Average  False                 SlotId
  Data Disk Read Operations/Sec   Per Disk Read Operations/Sec      CountPerSecond  Average  False                 SlotId
  Data Disk Write Operations/Sec  Per Disk Write Operations/Sec     CountPerSecond  Average  False                 SlotId
  Data Disk QD                    Per Disk QD                       Count           Average  False                 SlotId
  OS Disk Read Bytes/Sec          OS Per Disk Read Bytes/sec        CountPerSecond  Average  False
  OS Disk Write Bytes/Sec         OS Per Disk Write Bytes/sec       CountPerSecond  Average  False
  OS Disk Read Operations/Sec     OS Per Disk Read Operations/Sec   CountPerSecond  Average  False
  OS Disk Write Operations/Sec    OS Per Disk Write Operations/Sec  CountPerSecond  Average  False
  OS Disk QD                      OS Per Disk QD                    Count           Average  False
  ```

* how to get the metrics value

  ```bash
  az monitor metrics list \
    --output table \
    --resource /subscriptions/${SUB_ID}/resourceGroups/cn-nms-rg/providers/Microsoft.Compute/virtualMachines/cn-cwlc-01-vm \
    --metric 'Network In' \
    --interval PT1M --start-time 2022-06-19T00:00:00Z \
    --end-time 2022-06-19T23:59:59Z
  
  Timestamp            Name                         Slotid      Maximum
  -------------------  -------------------------  --------  -----------
  2018-04-02 21:35:00  Data Disk Write Bytes/Sec         1
  2018-04-02 21:36:00  Data Disk Write Bytes/Sec         1
  2018-04-02 21:37:00  Data Disk Write Bytes/Sec         1
  2018-04-02 21:38:00  Data Disk Write Bytes/Sec         1
  2018-04-02 21:39:00  Data Disk Write Bytes/Sec         1
  2018-04-02 21:40:00  Data Disk Write Bytes/Sec         1
  2018-04-02 21:41:00  Data Disk Write Bytes/Sec         1
  2018-04-02 21:42:00  Data Disk Write Bytes/Sec         1
  2018-04-02 21:43:00  Data Disk Write Bytes/Sec         1
  2018-04-02 21:44:00  Data Disk Write Bytes/Sec         1
  2018-04-02 21:45:00  Data Disk Write Bytes/Sec         1
  2018-04-02 21:46:00  Data Disk Write Bytes/Sec         1
  2018-04-02 21:47:00  Data Disk Write Bytes/Sec         1  1.01974e+08
  2018-04-02 21:48:00  Data Disk Write Bytes/Sec         1  1.02015e+08
  2018-04-02 21:49:00  Data Disk Write Bytes/Sec         1  1.02041e+08
  2018-04-02 21:50:00  Data Disk Write Bytes/Sec         1  1.01976e+08
  2018-04-02 21:51:00  Data Disk Write Bytes/Sec         1  6.37246e+07
  ```

  
