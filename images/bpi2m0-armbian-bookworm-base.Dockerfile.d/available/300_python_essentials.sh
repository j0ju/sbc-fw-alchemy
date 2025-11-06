#!/bin/sh -eu
# (C) 2023-2025 Joerg Jungermann, GPLv2 see LICENSE

. "$SRC/lib.sh"; init
PS4='> ${0##*/}: '
#set -x

chroot /target apt-get install -y \
  python3-pip \
  virtualenv \
  python3-smbus python3-smbus2 \
  python3-dev
