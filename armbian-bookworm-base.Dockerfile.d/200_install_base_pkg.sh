#!/bin/sh -eu
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

. "$SRC/lib.sh"; init
#set -x

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
