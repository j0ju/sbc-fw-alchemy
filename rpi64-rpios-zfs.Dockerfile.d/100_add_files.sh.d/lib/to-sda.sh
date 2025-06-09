#!/bin/sh
set -x
if [ $$ = 1 ]; then
  mount
  mount -t tmpfs tmpfs /var/tmp
  mount -t tmpfs tmpfs /tmp
  mount -w /boot/firmware
  /lib/systemd/systemd-udevd &
fi
sh /lib/rootfs-to.sh /dev/sda
sync

if [ $$ = 1 ]; then
  umount /boot/firmware
  echo s > /proc/sysrq-trigger
  sleep 3
  echo u > /proc/sysrq-trigger
  sleep 3
  echo b > /proc/sysrq-trigger
fi
