#!/bin/sh
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE
set -eu
umask 022

IMAGE="$1"

COMPRESSOR="${COMPRESSOR:-zstd}" # xz
BLOCKSIZE="${BLOCKSIZE:-512k}"   # 256k 512k

for glob in .git .etckeeper "*.apk-*" "*.dpkg-*" "*.ucf-*" "*-"; do
  find /target/etc/ -name "$glob" -exec rm -rf {} +
done

rm -f /target/etc/resolv.conf
ln -s ../run/resolv.conf /target/etc/resolv.conf

rm -rf /target/run /target/tmp /target/usr/share/doc
mkdir /target/run /target/tmp
chmod 1777 /target/tmp
chmod 0755 /target/run

GITREV="$( cd /src ; git log HEAD^..HEAD --oneline | awk '$0=$1' )"
DATE="$( date +%Y-%m-%d-%H:%M )"
VERSION="${IMAGE%%.*}-$DATE-$GITREV+dirty"
git status --short | grep -q ^ || \
  VERSION="${VERSION%+dirty}"

echo "$VERSION" > /target/boot/build.meta

rm -f "$IMAGE"
case "$0" in
  */gen-sqfs.sh )
    mksquashfs /target "$IMAGE" -b "$BLOCKSIZE" -comp "$COMPRESSOR" -quiet
    ;;
  */gen-erofs.sh )
    mkfs.erofs "$IMAGE" /target
    ;;
esac

[ -z "$OWNER" ] || \
  chown "$OWNER${GROUP:+:$GROUP}" "$IMAGE"

# vim: ts=2 sw=2 ft=sh et
