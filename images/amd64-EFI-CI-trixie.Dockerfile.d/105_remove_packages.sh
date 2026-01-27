#!/bin/sh -eu
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE
PS4='> ${0##*/}: '
set -eu

. "$SRC/lib.sh"; init
set -x

chroot "$DST" \
  apt-get remove --purge -y \
    dhcpcd dhcpcd-base \
    \
  #
#
