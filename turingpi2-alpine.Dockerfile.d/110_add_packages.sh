#!/bin/sh
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE
set -eu
umask 022

#- debug
  trap 'exit $?' EXIT
  PS4='> ${0##*/}: '
  set -x

mkdir -p /target/tmp/cache/apk /target/tmp/cache/etckeeper
#yes | chroot /target apk del git etckeeper
chroot /target apk add iptables iptables-openrc mtd-utils rdnssd
