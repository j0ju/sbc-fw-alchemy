#!/bin/sh
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE
set -eu
umask 022

PS4='> ${0##*/}: '
#set -x

mkdir -p /target/tmp/cache/apk /target/tmp/cache/etckeeper /target/tmp/cache/vim

chroot /target \
  apk add \
    dnsmasq \
    libgpiod \
    squashfs-tools \
    rdnssd \
# EO chroot /target apk add

rm -f /target/etc/.git/HEAD.lock
