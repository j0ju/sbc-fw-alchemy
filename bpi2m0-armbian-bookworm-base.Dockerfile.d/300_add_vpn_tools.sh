#!/bin/sh -eu
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

#set -x
. "$SRC/lib.sh"; init

chroot /target apt-get install -y \
  wireguard-tools fastd

chroot /target \
  systemctl disable fastd

chroot /target \
  systemctl mask fastd
