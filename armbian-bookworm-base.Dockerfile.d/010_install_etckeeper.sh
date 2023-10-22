#!/bin/sh -e
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
#set -x

chroot /target apt-get update
chroot /target apt-get install -y etckeeper
rm -f /target/etc/apt/apt.conf.d/02-armbian-postupdate
( cd /target/etc
  git config user.email "root@"
  git config user.name "root"
)
chroot /target etckeeper commit -m "armbian: disable /etc/apt/apt.conf.d/02-armbian-postupdate"
