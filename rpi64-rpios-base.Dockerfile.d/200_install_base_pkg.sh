#!/bin/sh -eu
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

. "$SRC/lib.sh"; init
#set -x

chroot /target \
  apt-get update

chroot /target \
  apt-get install -y \
    vim-nox mc \
    tmux \
    minicom lrzsz \
    tig \
    mtr-tiny \
    tcpdump strace \
    zstd pixz pigz unzip zip \
    busybox \
    sysstat ifstat \
    wavemon htop \
    bird2 \
    dmsetup lvm2 cryptsetup \
    btrfs-progs f2fs-tools \
    dropbear-initramfs \
    pv \
    sntp \
    ppp udhcpc \
    wireguard-tools fastd \
  # EO apt-get
# EO chroot
