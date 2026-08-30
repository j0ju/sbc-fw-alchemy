# How to install L4T on an OrinNX without SDK Manager or Jetpack just via PXE

Note: this has been tested on a NVidia Orin NX 16GB in Super config

## Boot Tegra board via PXE, use
 * `output/l4t-jetpack7.2.1.vmlinuz`
 * `output/l4t-jetpack7.2.1.initramfs.xz`

 Feel inspired by the grub snippet
 `docs/NetBoot/grub/grub.cfg.d/90_l4t_nvidia_jetson.cfg`.

 You need network access to the Jetson board, you can use the serial connection for typing commands
 or ssh (root:root).

## Get DTB and `/etc/nv_boot_control.conf`
 The DTBs reside below `/boot/dtb/`.

 For NVidia Orin NX 16GB in Super config you need
  * `tegra234-p3768-0000+p3767-0000-nv-super.dtb` see `images/l4t-jetpack7.2.1.Dockerfile.d/400_l4t_init-defaults.sh.d/extlinux.conf`
  * `docs/TuringPi2-Alpine/nv_boot_control.conf.OrinNX16GB` as `/etc/nv_boot_control.conf`

## Copy needed files to device booted into live initrd.
 The rootfs tarball and `nv_boot_control.conf` eg:
 ```
 rsync output/l4t-jetpack7.2.1.rootfs.tar.zst docs/TuringPi2-Alpine/nv_boot_control.conf.OrinNX16GB root@201.0.113.42:
 ```
 Use the correct IP for your PXE booted Tegra device.

 Copy `nv_boot_control.conf.OrinNX16GB` to `/etc/nv_boot_control.conf`
 Adapt OrinNX16GB to you board or provide a patch (please!).
 ```
 cp nv_boot_control.conf.OrinNX16GB /etc/nv_boot_control.conf
 ```
 From now on `nvbootctrl` is working.
 Ensure you are on slot A and the boot status is normal, otherwise L4TLoader will try to be a non-existend(yet!) recovery image.

 ```
 root@l4t:~# nvbootctrl dump-slots-info
 Current version: 39.2.1
 Capsule update status: 0
 Current bootloader slot: A
 Active bootloader slot: A
 num_slots: 2
 slot: 0,             status: normal
 slot: 1,             status: normal
 ```
 To activate slot A: `nvbootctrl set-active-boot-slot 0` if not already activated.
 You need to reboot after this if you are not on slot A.

 To set current slot to `normal` state, use `nvbootctrl verify`.
 You can ignore the message `Info: variable BootChainFwStatus is not found.`

## Install to disk
 ```
 rootfs-to.sh /dev/nvme0n1 l4t-jetpack7.2.1.rootfs.tar.zst
 ```

 Reboot and have fun.
 The default username ist nvidia (same password).
 Hostname is l4t.
