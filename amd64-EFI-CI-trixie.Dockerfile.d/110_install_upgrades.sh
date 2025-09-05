#!/bin/sh -eu
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE
PS4='> ${0##*/}: '
set -eu

. "$SRC/lib.sh"; init
#set -x

chroot /target apt-get full-upgrade -y

( cd /target/lib/modules
  ls [0-9]* -d 
) | sort | head -n -1 | while read ver; do 
  if [ -f "/target/var/lib/dpkg/info/linux-header-$ver.list" ]; then
    chroot /target dpkg -P linux-header-$ver
  fi
  if [ -f "/target/var/lib/dpkg/info/linux-image-$ver.list" ]; then
    chroot /target dpkg -P linux-image-$ver
  fi
done

apt-get clean
