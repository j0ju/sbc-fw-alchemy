#!/bin/sh
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE
set -eu
umask 022

PS4='> ${0##*/}: '
#set -x

mkdir -p /target/tmp/cache/apk /target/tmp/cache/etckeeper /target/tmp/cache/vim

chroot /target \
  apk add \
    iw wireless-tools \
    wpa_supplicant wpa_supplicant-openrc \
    hostapd hostapd-openrc \
    wavemon \
    sudo doas \
    cloud-init \
# EO chroot /target apk add
