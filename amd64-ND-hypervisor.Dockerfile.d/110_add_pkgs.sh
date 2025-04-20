#!/bin/sh -eu
. "$SRC/lib.sh"; init
set -x

chroot /target apt-get install -y \
  ifupdown2 \
  htop screen tmux vim-nox mc \
  tcpdump strace lsof \
  pciutils \
  zstd xz-utils \
  #
