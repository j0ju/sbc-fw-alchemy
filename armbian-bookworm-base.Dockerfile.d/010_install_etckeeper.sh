#!/bin/bash -e
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
#set -x

find /target/ -name .git -exec rm -rf {} \+

cp "$0.d/etc-dot-gitignore" /target/etc/.gitignore
( cd /target/etc
  git init .
  git add .gitignore
  git commit -m "initial commit"
  git add .
)

chroot /target apt-get install -y etckeeper
rm -f /target/etc/apt/apt.conf.d/02-armbian-postupdate
( cd /target/etc
  git config user.email "root@"
  git config user.name "root"
)
date
chroot /target etckeeper commit -m "armbian: disable /etc/apt/apt.conf.d/02-armbian-postupdate"
