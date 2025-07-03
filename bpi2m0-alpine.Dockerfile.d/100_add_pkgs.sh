#!/bin/sh
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE
set -eu
umask 022

PS4='> ${0##*/}: '
set -x

chroot /target \
  apk add \
    wpa_supplicant wpa_supplicant-openrc \
    hostapd hostapd-openrc \
    wavemon \
    sudo doas \
    cloud-init \
# EO chroot /target apk add
