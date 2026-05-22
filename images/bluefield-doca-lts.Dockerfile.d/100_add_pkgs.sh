#!/bin/sh -eu
# (C) 2023-2025 Joerg Jungermann, GPLv2 see LICENSE

. "$SRC/lib.sh"; init
#set -x

chroot /target \
  apt-get install -y \
    vim-nox \
    mc \
    screen \
    tmux \
  # EO dpkg
# EO chroot
