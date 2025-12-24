#!/bin/sh -eu
# (C) 2023-2025 Joerg Jungermann, GPLv2 see LICENSE

. "$SRC/lib.sh"; init
#set -x

SVC_DISABLE="
  NetworkManager.service NetworkManager-wait-online.service NetworkManager-dispatcher.service dbus-org.freedesktop.nm-dispatcher.service
  ModemManager.service dbus-org.freedesktop.ModemManager1.service
  avahi-daemon.service avahi-daemon.socket dbus-org.freedesktop.Avahi.service
  triggerhappy.service triggerhappy.socket
  userconfig.service
  udisks2.service
  systemd-networkd-wait-online.service
  resize2fs_once.service
  systemd-networkd-wait-online.service
  avahi-daemon.socket avahi-daemon.service
  wpa_supplicant.service
  bird.service
  fastd.service
  dnsmasq.service
  rdnssd.service
"

SVC_MASK="
  systemd-networkd-wait-online.service
  wpa_supplicant.service
  fastd.service
"

SVC_ENABLE="
  ssh.service
  systemd-networkd.service
  systemd-resolved.service
  systemd-timesyncd.service
  etc-machine-id.service
"
chroot /target \
  apt-get install -y \
    systemd-resolved systemd-timesyncd
  #

# systemctl disable has issues in chroot with aliases
for svc in $SVC_DISABLE; do
  find /target/etc/systemd/system -type l -name "$svc" -delete -print
done

# systemctl disable has issues in chroot with aliases
for svc in $SVC_MASK; do
  ln -s /dev/null "/target/etc/systemd/system/$svc"
done

chroot /target \
  systemctl enable $SVC_ENABLE
