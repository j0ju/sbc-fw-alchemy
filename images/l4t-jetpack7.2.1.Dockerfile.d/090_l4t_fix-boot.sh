#!/bin/sh
# (C) 2025-26 Joerg Jungermann, GPLv2 see LICENSE
set -eu
PS4='> ${0##*/}: '
umask 022

set -x # DEBUG

KVER="$( cd "$DST/lib/modules"; ls -d [0-9]* | sort | head )"
# Jetpack 7.2.1
#KVER="6.8.12-1021-tegra"

# symlink boot -> .
# so L4TLoader can still user /boot/KERNEL, /boot/INITRD or /boot/dtb/DTFFILE
rm -rf "$DST/boot/boot"
ln -s . "$DST/boot/boot"

# put DTB to subdir
mkdir -p "$DST/boot/dtb"
mv "$DST/boot"/*.dtb* "$DST/boot/dtb"

mv "$DST/boot/Image" "$DST/boot/vmlinuz-$KVER"
ln -s "vmlinuz-$KVER" "$DST/boot/vmlinuz"

mv "$DST/boot/initrd" "$DST/boot/initrd.l4t"

mkdir -p "$DST/boot/efi/EFI/BOOT"
cp /Linux_for_Tegra/bootloader/BOOTAA64.efi "$DST/boot/efi/EFI/BOOT"
