#!/bin/sh
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE
set -eu

IMAGE="$1"

COMPRESSOR="${COMPRESSOR:-zstd}" # xz
BLOCKSIZE="${BLOCKSIZE:-1024k}"  # 256k 512k

rm -f /target/etc/resolv.conf
find /target/ -name ".git" -exec rm -rf {} +
find /target/etc/ -name "*.apk-*" -o -name "*.dpkg-*" -o -name "*.ucf-*" -o -name "*-" -delete
ln -s ../run/resolv.conf /target/etc/resolv.conf

GITREV="$( cd /src ; git log HEAD^..HEAD --oneline | awk '$0=$1' )"
DATE="$( date +%Y-%m-%d-%H:%M )"
VERSION=$DATE-$GITREV+dirty
git status --short | grep -q ^ || \
  VERSION="${VERSION%+dirty}"

echo "$VERSION" > /target/boot/build.meta

rm -f "$IMAGE"
mksquashfs /target "$IMAGE" -b "$BLOCKSIZE" -comp "$COMPRESSOR" -quiet


[ -z "$OWNER" ] || \
  chown "$OWNER${GROUP:+:$GROUP}" "$IMAGE"

# vim: ts=2 sw=2 ft=sh et
