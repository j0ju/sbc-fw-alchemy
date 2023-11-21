#!/bin/sh -eu
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
#set -x

. "$SRC/lib.sh"; init

rm -f /target/etc/systemd/system/dbus-fi.w1.wpa_supplicant1.service

chroot /target \
  systemctl mask dbus-fi.w1.wpa_supplicant1.service

chroot /target \
  systemctl mask wpa_supplicant.service

chroot /target \
  systemctl unmask wpa_supplicant@.service
chroot /target \
  systemctl enable wpa_supplicant@wlan0.service
