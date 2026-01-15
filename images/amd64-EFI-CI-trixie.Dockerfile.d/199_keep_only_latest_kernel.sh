#!/bin/sh -eu
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE
PS4='> ${0##*/}: '
set -eu

. "$SRC/lib.sh"; init
set -x

( cd "$DST"/lib/modules
  ls [0-9]* -d
) | sort | head -n -1 | while read ver; do
  for i in "$DST/var/lib/dpkg/info/linux-headers-$ver-"*".list" "$DST/var/lib/dpkg/info/linux-image-$ver.list"; do
    [ -f "$i" ] || continue
    p="${i##*/}"
    p="${p%.*}"
    chroot "$DST" dpkg -P "$p"
  done
done
