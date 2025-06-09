#!/bin/sh -eu
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

. "$SRC/lib.sh"; init
#set -x

echo "pi:raspberry" |
  chroot /target \
    chpasswd
