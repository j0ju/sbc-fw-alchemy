#!/bin/sh -eu
# (C) 2023-2025 Joerg Jungermann, GPLv2 see LICENSE

. "$SRC/lib.sh"; init
. "$SRC/100_add_files.sh"

SHOPTS="$(echo $- | tr -cd 'eux')"
chroot /target /bin/sh -$SHOPTS <<EOF
  PS4="${PS4% }:chroot: "

  cd /boot/overlay-user
  make
  make enable
EOF
