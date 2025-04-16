#!/bin/sh -eu
. "$SRC/lib.sh"; init
set -x

chroot /target apt-get install -y \
  ifupdown-ng \
  tcpdump htop screen tmux \
  pciutils ethtool lsof strace dmidecode \
  mc tmux minicom vim-nox \
  zstd xz-utils \
  e2fsprogs xfsprogs btrfs-progs \
  #
