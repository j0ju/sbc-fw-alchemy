#!/bin/sh -eu
# (C) 2025-2026 Joerg Jungermann, GPLv2 see LICENSE
PS4='> ${0##*/}: '
set -eu
. "$SRC/lib.sh"; init

rm -f /usr/sbin/grub-install
dpkg-divert --rename --remove /usr/sbin/grub-install
