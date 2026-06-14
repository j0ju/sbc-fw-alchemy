#!/bin/sh -eu
# (C) 2023-2026 Joerg Jungermann, GPLv2 see LICENSE

. "$SRC/lib.sh"; init
set -x

# add busybox
cp /target/bin/busybox /initramfs/bin/busybox

# add zstd
chroot /target ldd /bin/zstd | grep -oE "/[^ ]+" | while read f; do
  cp "/target/$f" "/initramfs/$f"
done
