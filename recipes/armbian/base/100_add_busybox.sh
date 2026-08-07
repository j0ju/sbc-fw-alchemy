#!/bin/sh -eu
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE
PS4='> ${0##*/}: '
set -eu
. "$SRC/lib.sh"; init

chroot /target apt-get install -y \
  busybox

# vim: ts=2 sw=2 et
