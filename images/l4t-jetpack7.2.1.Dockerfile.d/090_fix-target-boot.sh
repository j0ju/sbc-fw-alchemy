#!/bin/sh
# (C) 2025-26 Joerg Jungermann, GPLv2 see LICENSE
set -eu
PS4='> ${0##*/}: '
umask 022

set -x # DEBUG

# Jetpack 7.2.1
KVER="6.8.12-1021-tegra"

mv "$DST/boot/Image" "$DST/boot/vmlinuz-$KVER"
ln -s "vmlinuz-$KVER" "$DST/boot/vmlinuz"
ln -s "vmlinuz-$KVER" "$DST/boot/Image"

mv "$DST/boot/initrd" "$DST/boot/initrd-$KVER"
ln -s "initrd-$KVER" "$DST/boot/initrd"
