# BFB: dump-initramfs-v0 - initramfs-bootflow

## /bfb/dump-initramfs-v0

* init == systemd / dracut
* /etc/systemd/system/initrd.target.wants/install-ubuntu.service
  SYMLINK -->  
  /usr/lib/systemd/system/install-ubuntu.service
* /scripts/initrd-install 
* /ubuntu/install.sh


## /usr/lib/systemd/system/install-ubuntu.service
``` /usr/lib/systemd/system/install-ubuntu.service
[Unit]
Description=Install ubuntu Linux
After=initrd-root-fs.target initrd-parse-etc.service
After=dracut-initqueue.service dracut-mount.service

[Service]
Type=oneshot
ExecStart=/scripts/initrd-install
StandardInput=null
StandardOutput=syslog
StandardError=syslog+console

```

## /scripts/initrd-install

```
#!/bin/bash

printf_msg()
{
        echo "$@" > /dev/kmsg
        return 0
}

modprobe nls_iso8859-1 > /dev/null 2>&1
modprobe -a sdhci-of-dwcmshc dw_mmc-bluefield > /dev/null 2>&1
modprobe mlxbf_tmfifo > /dev/null 2>&1
modprobe -a ipmi_msghandler ipmi_devintf i2c-mlxbf
modprobe ipmb_host slave_add=0x10
echo ipmb-host 0x1011 > /sys/bus/i2c/devices/i2c-1/new_device
insmod /mlx-bootctl.ko > /dev/null 2>&1
insmod /sbsa_gwdt.ko > /dev/null 2>&1
/usr/sbin/watchdog > /dev/null 2>&1

printf_msg "================================="
printf_msg "Installing ubuntu. Please wait..."
printf_msg "================================="

/bin/bash /ubuntu/install.sh
if [ $? -eq 0 ]; then
        printf_msg "==================================="
        printf_msg "Installation finished. Rebooting..."
        printf_msg "==================================="
        printf_msg
        sleep 3
        reboot -f
else
        printf_msg "========================"
        printf_msg "Failed to install ubuntu"
        printf_msg "========================"
fi
```

##  /ubuntu/install.sh

```
[root@6e68b0266eed:/bfb/dump-initramfs-v0/ubuntu]# tree -h
[   5]  .
├── [1.3G]  image.tar.xz
├── [   6]  install.env
│   ├── [1.6K]  atf-uefi
│   ├── [ 40K]  bmc
│   ├── [ 27K]  common
│   └── [5.8K]  nic-fw
└── [ 21K]  install.sh

2 directories, 6 files
```


