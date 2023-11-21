#!/bin/sh -eu
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
#set -x

find /target/ -name .git -exec rm -rf {} \+

( cd /target/etc
  git init .
  git config user.email "root@"
  git config user.name "root"
)
cp "$0.d/etc-dot-gitignore" /target/etc/.gitignore

chroot /target apt-get install -y etckeeper
rm -f /target/etc/apt/apt.conf.d/02-armbian-postupdate
chroot /target etckeeper commit -m "armbian: disable /etc/apt/apt.conf.d/02-armbian-postupdate"
