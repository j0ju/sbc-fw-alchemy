#!/bin/sh -eu
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE
PS4='> ${0##*/}: '
set -eu

. "$SRC/lib.sh"; init

cat > /target/etc/initramfs-tools/modules <<EOF
ext4
btrfs
f2fs
zfs
squashfs
loop
EOF

KVER="$(cd /target/lib/modules/; ls [0-9]* -d | head -n 1)"
chroot /target update-initramfs -k$KVER -u

# vim: ts=2 sw=2 et
