#!/bin/sh -eu
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

. "$SRC/lib.sh"; init
. "$SRC/100_add_files.sh"
#set -x

SHOPTS="$(echo $- | tr -cd 'eux')"
PREFIX=/opt/pi-hat-ep-0118

chroot /target /bin/sh -$SHOPTS <<EOF
  PS4="${PS4% }:chroot: "
  umask 022

  virtualenv -p python3 "$PREFIX"
  cd "$PREFIX"

  bin/pip3 install pi-ina219
EOF
