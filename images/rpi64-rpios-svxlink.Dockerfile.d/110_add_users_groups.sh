#!/bin/sh -eu
# (C) 2023-2025 Joerg Jungermann, GPLv2 see LICENSE

. "$SRC/lib.sh"; init
#set -x

chroot /target /bin/sh -eu << EOF
  groupadd -g 73 -r svxlink
  useradd svxlink -g 73 -M -r -u 73

  usermod -a -G gpio svxlink
  usermod -a -G audio svxlink
  usermod -a -G plugdev svxlink
EOF
