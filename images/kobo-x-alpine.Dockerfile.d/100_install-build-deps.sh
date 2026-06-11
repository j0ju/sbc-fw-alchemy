#!/bin/sh
# (C) 2025,2026 Joerg Jungermann, GPLv2 see LICENSE
set -eu
umask 022

PS4='> ${0##*/}: '
set -x

cd /target

mkdir -p \
  tmp/cache/apk \
  tmp/cache/etckeeper \
  tmp/cache/vim \
# EO

chroot /target \
  apk add \
    alpine-sdk xorg-server-dev libx11-dev libxdamage-dev libxfixes-dev
