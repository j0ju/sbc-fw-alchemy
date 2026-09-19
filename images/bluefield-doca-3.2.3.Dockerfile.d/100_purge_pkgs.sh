#!/bin/sh -eu
# (C) 2023-2026 Joerg Jungermann, GPLv2 see LICENSE

. "$SRC/lib.sh"; init
#set -x

# purge uneeded pkgs, vim-tiny -> vim-nox
chroot /target \
  apt-get purge -y \
    vim-tiny \
    nano \
    command-not-found \
  # EO dpkg
# EO chroot

chroot /target \
  apt-get autoremove --purge -y
