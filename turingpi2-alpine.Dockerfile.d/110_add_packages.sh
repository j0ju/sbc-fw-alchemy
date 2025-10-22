#!/bin/sh
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE
set -eu
umask 022

#- debug
  trap 'exit $?' EXIT
  PS4='> ${0##*/}: '
  #set -x

mkdir -p /target/tmp/cache/apk /target/tmp/cache/etckeeper

PKGS=

# platform speceifc
PKGS="$PKGS
  iptables iptables-openrc
  mtd-utils rdnssd zram-init
  u-boot-tools
  usbutils hwids-usb
  busybox-mdev-openrc
  f2fs-tools e2fsprogs dosfstools mtools
  sfdisk sgdisk partx blkid wipefs
  kmod
  mount
  wget
  util-linux util-linux-misc
    util-linux-bash-completion
  ppp-chat
  erofs-utils
  attr
  rsync
"

# network core
PKGS="$PKGS
  ifupdown-ng ifupdown-ng-iproute2 ifupdown-ng-wireguard ifupdown-ng-wireguard-quick
  openresolv
  avahi avahi-tools
  rdnssd
  keepalived
  bird2
" # EO PKGS

# user convinience and debugging extras
PKGS="$PKGS
  vim
  tmux
  minicom
  pv
"
chroot /target apk add $PKGS

find /target/etc -name "*.apk-*" -delete
