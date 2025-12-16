#!/bin/sh
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE
set -eu
umask 022

# this does:
#  * build of rkdevelop

#- debug
  trap 'exit $?' EXIT
  PS4='> ${0##*/}: '
  set -x

#- settings
  GIT_URL=https://github.com/rockchip-linux/rkdeveloptool.git
  GIT_REF=HEAD # latest is greatest
  #GIT_REF=304f073 # known good

  ROOT=/workspace/alpine.build-rkdev
  PREFIX=/opt/rockchip

#- ensure build env
  rm -rf "$ROOT"
  mkdir -p "$ROOT"/src
  tar xf /src/input/armhf-Alpine-3.22.tgz -C "$ROOT"
  rm -f "$ROOT"/etc/resolv.conf
  cat /etc/resolv.conf > "$ROOT"/etc/resolv.conf
  cp -a /dev/* "$ROOT/dev"
  mkdir -p "$ROOT"/tmp/cache/etckeeper "$ROOT"/tmp/cache/apk

#- add packages to build env
  chroot "$ROOT" \
    apk add \
      bash gcc automake autoconf libusb-dev make gawk zlib zlib-dev musl-dev g++

#- fetch sources
  git clone "$GIT_URL"  "$ROOT"/src/rkdevelop

#- build rkdevelop
chroot "$ROOT" /bin/sh -eu <<EOchroot
  PS4='> ${0##*/}:build rkdevelop: '
  umask 022
  set -x

  cd /src/rkdevelop
  ./autogen.sh
  ./configure --prefix="$PREFIX"
  make
  make install
  strip -g "$PREFIX/bin/rkdeveloptool"
EOchroot

mkdir -p  /src/"${1%/*}"
: > /src/"$1"
[ -z "$OWNER" ] || \
  chown "$OWNER${GROUP:+:$GROUP}" /src/"$1" /src/"${1%/*}"

chroot "$ROOT" tar cf - "$PREFIX" | zstd > /src/"$1"
