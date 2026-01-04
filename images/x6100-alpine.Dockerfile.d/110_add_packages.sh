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
  linuxconsoletools
"

# network core
PKGS="$PKGS
  avahi avahi-tools
  rdnssd
" # EO PKGS

PKGS="$PKGS
  networkmanager
    networkmanager-wifi
    networkmanager-bluetooth
    networkmanager-bash-completion
    networkmanager-openrc
    networkmanager-tui
    networkmanager-cli
  wireless-tools iw
  wavemon
" # EO PKGS

# user convinience and debugging extras
PKGS="$PKGS
  vim
  tmux
  screen
  minicom
  pv
  squashfs-tools
  libgpiod
" # EO PKGS

# useful apps
PKGS="$PKGS
  podman
    podman-docker podman-openrc podman-bash-completion
  podman-compose
    podman-compose-bash-completion
  podman-tui
" # EO PKGS

PKGS="$PKGS
  fbida-fbi
" # EO PKGS

PKGS="$PKGS
  alsa-utils alsa-tools
    alsa-tools-gui
    alsa-topology-conf
    alsa-plugins
    alsa-ucm-conf
    alsa-utils-openrc
  alsaconf
  bluez
    bluez-openrc bluez-btmgmt bluez-btmon bluez-obexd bluez-firmware bluez-hid2hci
    bluez-alsa bluez-alsa-openrc bluez-alsa-utils
    py3-bluez-pyc py3-bluez
  cmus mpg123 lame
    cmus-bash-completion
" # EO PKGS

chroot /target apk add $PKGS

find /target/etc -name "*.apk-*" -delete
