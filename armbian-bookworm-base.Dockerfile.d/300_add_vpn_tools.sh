#!/bin/sh -e
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
#set -x

. "$SRC/lib.sh"; init

chroot /target apt-get install -y \
  wireguard-tools fastd

chroot /target \
  systemctl disable fastd

chroot /target \
  systemctl mask fastd
