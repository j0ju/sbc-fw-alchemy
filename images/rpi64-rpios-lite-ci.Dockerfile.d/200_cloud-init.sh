#!/bin/sh -eu
# (C) 2023-2025 Joerg Jungermann, GPLv2 see LICENSE

. "$SRC/lib.sh"; init
#set -x

chroot /target \
  apt-get install -y \
    cloud-init \
    netplan.io \
  # EO apt-get
# EO chroot
