#!/bin/sh -eu
# (C) 2023-2026 Joerg Jungermann, GPLv2 see LICENSE

. "$SRC/lib.sh"; init
set -x

# add modules of interest
cp -a /target/lib/modules/*/kernel/fs/f2fs /initramfs/lib/modules/*/kernel/fs
cp -a /target/lib/modules/*/kernel/lib     /initramfs/lib/modules/*/kernel
cp -a /target/lib/modules/*/updates        /initramfs/lib/modules/[1-9]*/

# depack all modules so xz on building the initramfs file can compress better
find /initramfs/lib/modules -type f -name "*.ko.zst" -exec zstd -df {} \;
find /initramfs/lib/modules -type f -name "*.ko.zst" -delete

# rerun depmod
depmod -b /initramfs $(cd /initramfs/lib/modules; ls -d [1-9].*)
