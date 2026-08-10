#!/bin/sh -eu
# (C) 2025,2026 Joerg Jungermann, GPLv2 see LICENSE
PS4='> ${0##*/}: '
set -eu

. "$SRC/lib.sh"; init

cat > $DST/etc/initramfs-tools/modules <<EOF
ext4
btrfs
f2fs
xfs
zfs
squashfs
loop
EOF

KVER="$(cd $DST/lib/modules/; ls [0-9]* -d | head -n 1)"
chroot ${DST:-/} update-initramfs -k$KVER -u

# vim: ts=2 sw=2 et
