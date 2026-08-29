#!/bin/sh
# (C) 2024-26 Joerg Jungermann, GPLv2 see LICENSE
set -eu
PS4='> ${0##*/}: '
umask 022

set -x # DEBUG

KVER="$( cd "$DST/lib/modules"; ls -d [0-9]* | sort | head )"

# regenerate /target/boot/initrd - have a bit more advanced debug environment
( cd /initramfs
  find . | cpio --create --format=newc --quiet | zstd
) > "$DST/boot/initrd.img-$KVER"
ln -s initrd.img-$KVER "$DST/boot/initrd.img"
rm -f "$DST/initrd.l4t*"
