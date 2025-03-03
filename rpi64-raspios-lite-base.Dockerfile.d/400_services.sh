#!/bin/sh -eu
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

. "$SRC/lib.sh"; init
#set -x

chroot /target \
  systemctl disable \
    NetworkManager.service  NetworkManager-wait-online.service   NetworkManager-dispatcher.service \
    ModemManager.service \
    triggerhappy.service triggerhappy.socket \
    dphys-swapfile.service \
    userconfig.service \
    udisks2.service \
    systemd-networkd-wait-online.service \
    resize2fs_once.service \
    systemd-networkd-wait-online.service \
    avahi-daemon.socket avahi-daemon.service \
    wpa_supplicant.service \
    bird \
    fastd \
  #

chroot /target \
  systemctl mask \
    systemd-networkd-wait-online.service \
    wpa_supplicant.service \
    fastd \
  #

chroot /target \
  apt-get install -y \
    systemd-resolved systemd-timesyncd
  #

chroot /target \
  systemctl enable \
    ssh.service \
    systemd-networkd \
    systemd-resolved \
    systemd-timesyncd \
  #
