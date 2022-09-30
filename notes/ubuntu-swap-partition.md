## create swap file

```
sudo dd if=/dev/zero of=/swap_file bs=1024 count=4096000

sudo chmod 600 /swap_file

sudo mkswap /swap_file

sudo swapon  /swap_file
```

## add following lines to /etc/fstab

```
/swap_file   swap   swap  defaults  0 0
```
