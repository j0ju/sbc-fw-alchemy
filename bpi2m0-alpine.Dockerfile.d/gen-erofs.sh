#!/bin/sh
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE
set -eu
umask 022

IMAGE="$1"

rm -f /target/etc/resolv.conf
rm -rf /target/etc/.git
ln -s ../run/resolv.conf /target/etc/resolv.conf

rm -rf /target/run /target/tmp
mkdir /target/run /target/tmp
chmod 1777 /target/tmp
chmod 0755 /target/run

GITREV="$( cd /src ; git log HEAD^..HEAD --oneline | awk '$0=$1' )"
DATE="$( date +%Y-%m-%d-%H:%M )"
VERSION=$DATE-$GITREV+dirty
git status --short | grep -q ^ || \
  VERSION="${VERSION%+dirty}"

echo "$VERSION" > /target/boot/build.meta

rm -f "$IMAGE"
mkfs.erofs "$IMAGE" /target

[ -z "$OWNER" ] || \
  chown "$OWNER${GROUP:+:$GROUP}" "$IMAGE"

# vim: ts=2 sw=2 ft=sh et
