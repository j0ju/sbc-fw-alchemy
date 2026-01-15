#!/bin/sh -eu
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE
PS4='> ${0##*/}: '
set -eu

. "$SRC/lib.sh"; init
set -x

rm -f /usr/sbin/update-initramfs
dpkg-divert --rename --divert /usr/sbin/update-initramfs.real --remove /usr/sbin/update-initramfs
if [ -f  /run/initrd.rebuild ]; then
  update-initramfs -kall -c
  rm /run/initrd.rebuild
fi
