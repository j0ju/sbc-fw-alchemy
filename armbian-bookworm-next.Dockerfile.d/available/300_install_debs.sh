#!/bin/sh -eu
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

. "$SRC/lib.sh"; init
. "$SRC/100_add_files.sh"
#set -x

SHOPTS="$(echo $- | tr -cd 'eux')"

chroot /target /bin/sh -$SHOPTS <<EOF
  PS4="${PS4% }:chroot: "

  for deb in /root/*.deb; do
    [ -f "\$deb" ] || \
      break
    dpkg -i /root/*.deb
    rm -f /root/*.deb
    break
  done
EOF
