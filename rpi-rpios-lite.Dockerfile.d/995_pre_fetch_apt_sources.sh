#!/bin/sh -eu
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

set -eu
PS4='> ${0##*/}: '
#set -x

mv /target/etc/resolv.conf /target/etc/resolv.conf.dist
cp /etc/resolv.conf /target/etc/resolv.conf
chroot /target apt-get update
rm -f /target/etc/resolv.conf
mv /target/etc/resolv.conf.dist /target/etc/resolv.conf
