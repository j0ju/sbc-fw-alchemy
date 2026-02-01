#!/bin/sh
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE
set -eu
umask 022

# this does:
#  * build of rpiboot
#
# NOTE: as long rpiboot is in alpine edge/testing, use this
# TODO: migrate if it is in stable

#- debug
  trap 'exit $?' EXIT
  PS4='> ${0##*/}: '
  set -x

#- settings
  ROOT=/workspace/alpine.build-rpiboot
  PREFIX=/opt/rpiboot

#- ensure build env
  rm -rf "$ROOT"
  mkdir -p "$ROOT"/src
  tar xf /src/input/armv7-Alpine-3.23.tgz -C "$ROOT"
  rm -f "$ROOT"/etc/resolv.conf
  cat /etc/resolv.conf > "$ROOT"/etc/resolv.conf
  cp -a /dev/* "$ROOT/dev"
  mkdir -p "$ROOT"/tmp/cache/etckeeper "$ROOT"/tmp/cache/apk

#- add packages to build env
  chroot "$ROOT" \
    apk add \
      bash gcc automake autoconf libusb-dev make gawk zlib zlib-dev musl-dev

#- fetch sources
  git clone --recurse-submodules --shallow-submodules --depth=1 https://github.com/raspberrypi/usbboot "$ROOT"/src/rpiboot

#- build & install
chroot "$ROOT" /bin/sh -eu <<EOchroot
  PS4='> ${0##*/}:build rkdevelop: '
  umask 022
  set -x

  cd /src/rpiboot
  make INSTALL_PREFIX="$PREFIX"

  mkdir -p "$PREFIX"/bin
  cp -a rpiboot "$PREFIX"/bin/rpiboot
  strip -g "$PREFIX"/bin/rpiboot
EOchroot

mkdir -p  /src/"${1%/*}"
: > /src/"$1"
[ -z "$OWNER" ] || \
  chown "$OWNER${GROUP:+:$GROUP}" /src/"$1" /src/"${1%/*}"

chroot "$ROOT" tar cf - "$PREFIX" | zstd > /src/"$1"
