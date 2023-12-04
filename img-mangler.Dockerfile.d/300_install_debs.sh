#!/bin/sh -eu
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

. "$SRC/lib.sh"; init
. "$SRC/100_add_files.sh"
set -x

DST="${DST:-/}"
SHOPTS="$(echo $- | tr -cd 'eux')"

eval "$(chroot $DST dpkg-architecture)"

chroot "$DST" /bin/sh -$SHOPTS <<EOF
  PS4="${PS4% }:chroot: "

  for deb in /root/*_$DEB_HOST_ARCH.deb; do
    [ -f "\$deb" ] || \
      break
    dpkg -i /root/*_$DEB_HOST_ARCH.deb
    rm -f /root/*.deb
    break
  done
EOF
