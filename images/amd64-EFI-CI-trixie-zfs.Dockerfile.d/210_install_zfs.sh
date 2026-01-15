#!/bin/sh -eu
# (C) 2024-2026 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
set -eu

. "$SRC/lib.sh"; init
set -x

chroot "$DST" apt-get install -y \
    linux-headers-amd64 \
    zfs-dkms \
    zfs-initramfs \
    zfsutils-linux \
# EO apt-get
