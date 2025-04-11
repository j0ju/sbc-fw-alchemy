#!/bin/sh -eu
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
set -eu
#set -x

chroot /target apt-get clean
chroot /target apt-get install -yd live-boot live-config
mkdir -p /prefetch.deb
mv /target/var/cache/apt/archives/*.deb /prefetch.deb
