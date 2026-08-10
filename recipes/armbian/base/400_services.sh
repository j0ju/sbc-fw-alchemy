#!/bin/sh -eu
# (C) 2023-2026 Joerg Jungermann, GPLv2 see LICENSE

. "$SRC/lib.sh"; init
#set -x

chroot "${DST:-/}" \
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
    armbian-firstrun armbian-hardware-monitor armbian-ramlog armbian-zram-config \
  #

chroot "${DST:-/}" \
  systemctl mask \
    systemd-networkd-wait-online.service \
    wpa_supplicant.service \
    fastd \
    armbian-firstrun armbian-hardware-monitor armbian-ramlog armbian-zram-config \
  #

chroot "${DST:-/}" \
  apt-get install -y \
    systemd-resolved systemd-timesyncd
  #

chroot "${DST:-/}" \
  systemctl enable \
    ssh.service \
    systemd-networkd \
    systemd-resolved \
    systemd-timesyncd \
  #
