#!/bin/sh -eu
# (C) 2023-2026 Joerg Jungermann, GPLv2 see LICENSE
set -eu
set -x

cp /etc/resolv.conf /initrd/etc/resolv.conf

# add needed pkgs to alpine
chroot /initrd.alpine apk add \
  udev wget vim dropbear mc strace

# copy over coustomized udev config modules and firmware
( cd /initramfs
  tar cf -  lib/firmware lib/modules etc/udev *.ko*
) |\
  tar xf - -C /initrd.alpine

# move trampoline initrd.alpine to /initramfs
rm -rf /initramfs
mv /initrd.alpine /initramfs

# copy trampoline init
rm -f /initramfs/init /initramfs/sbin/init

cp "$0.d/init.sh" /initramfs/sbin/init
ln -s sbin/init /initramfs/init
chmod 755 /initramfs/sbin/init

# fixup some files
( cd /initramfs
  mv mlx-bootctl.ko mlx-bootctl.ko.zst
  rm sbin/logread sbin/syslogd
  ln -s busybox.static sbin/logread
  ln -s busybox.static sbin/syslogd
)
