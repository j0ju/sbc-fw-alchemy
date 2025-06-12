#!/bin/sh -eu
# (C) 2023-2025 Joerg Jungermann, GPLv2 see LICENSE

#set -x
. "$SRC/lib.sh" # no init

# compiles all user supplied device tree overlay in /boot/overlay-user 
# and enabled them

SHOPTS="$(echo $- | tr -cd 'eux')"
chroot /target /bin/sh -$SHOPTS <<EOF
  PS4="${PS4% }:chroot: "
  cd /boot/overlay-user
  make enable
EOF
