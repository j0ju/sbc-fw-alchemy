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
  avahi avahi-tools
  rdnssd
" # EO PKGS

# user convinience and debugging extras
PKGS="$PKGS
  vim
  tmux
  screen
  minicom
  pv
  squashfs-tools
"
chroot /target apk add $PKGS

find /target/etc -name "*.apk-*" -delete
