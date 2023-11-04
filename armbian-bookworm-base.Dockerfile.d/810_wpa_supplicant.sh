#!/bin/sh -e
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
#set -x

chroot /target \
  systemctl unmask wpa_supplicant@
chroot /target \
  systemctl enable wpa_supplicant@wlan0
