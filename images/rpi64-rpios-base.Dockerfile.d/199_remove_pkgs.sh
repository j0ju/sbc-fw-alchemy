#!/bin/sh -eu
# (C) 2023-2025 Joerg Jungermann, GPLv2 see LICENSE

. "$SRC/lib.sh"; init
#set -x

chroot /target \
  dpkg -P \
    vim-tiny \
    nano \
    isc-dhcp-common isc-dhcp-client \
    dhcpcd dhcpcd5 \
  # EO dpkg
# EO chroot
