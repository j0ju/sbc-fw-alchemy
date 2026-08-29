#!/bin/sh
# (C) 2025,2026 Joerg Jungermann, GPLv2 see LICENSE
set -eu
. "$SRC/lib.sh"; init

#set -x # DEBUG

# add packages to rootfs
chroot "$DST" apt-get install --no-install-recommends -y \
  btrfs-progs \
  mc screen tmux minicom vim-nox \
  rsync \
  zram-tools \
  strace tcpdump \
  #
