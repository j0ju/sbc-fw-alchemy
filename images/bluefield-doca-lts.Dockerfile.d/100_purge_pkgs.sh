#!/bin/sh -eu
# (C) 2023-2025 Joerg Jungermann, GPLv2 see LICENSE

. "$SRC/lib.sh"; init
#set -x

chroot /target \
  apt-get purge -y \
    vim-tiny \
    nano \
    command-not-found \
  # EO dpkg
# EO chroot

chroot /target \
  apt-get autoremove --purge -y
