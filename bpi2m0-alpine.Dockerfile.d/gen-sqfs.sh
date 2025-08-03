#!/bin/sh
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE
set -eu

IMAGE="$1"

COMPRESSOR="xz"
BLOCKSIZE=256k

rm -f /target/etc/resolv.conf
rm -rf /target/etc/.git
ln -s ../run/resolv.conf /target/etc/resolv.conf

rm -f "$IMAGE"
mksquashfs /target "$IMAGE" -b "$BLOCKSIZE" -comp "$COMPRESSOR"

[ -z "$OWNER" ] || \
  chown "$OWNER${GROUP:+:$GROUP}" "$IMAGE"

# vim: ts=2 sw=2 ft=sh et
