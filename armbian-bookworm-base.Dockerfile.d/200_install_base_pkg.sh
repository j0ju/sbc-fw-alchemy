#!/bin/sh -eu
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
#set -x

. "$SRC/lib.sh"; init

chroot /target \
  apt-get install -y \
    vim-nox mc \
    screen tmux \
    minicom lrzsz \
    tig \
    mtr-tiny \
    tcpdump strace \
    zstd pixz pigz unzip zip \
    busybox \
    sysstat ifstat \
    wavemon htop \
  # EO apt-get
# EO chroot
