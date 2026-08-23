#!/bin/sh
# (C) 2025,2026 Joerg Jungermann, GPLv2 see LICENSE
set -eu
umask 022

PS4='> ${0##*/}: '
set -x

chroot "$DST" apt-get install -y \
  grub-efi btrfs-progs \
  mc screen tmux minicom vim-nox \
  rsync \
  #

FSDIR="$0.d"
mkdir -p "$DST"/usr/local/bin
cp "$FSDIR"/rootfs-to.sh  "$DST"/usr/local/bin/rootfs-to.sh
chmod 0755 "$DST"/usr/local/bin/rootfs-to.sh
