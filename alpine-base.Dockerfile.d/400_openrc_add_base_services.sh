#!/bin/sh -eu
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

. "$SRC/lib.sh"; init
#set -x

chroot /target /bin/sh << EOF
  rc-update add devfs
  rc-update add fsck
  rc-update add localmount
  rc-update add root
  rc-update add sysfs
EOF
