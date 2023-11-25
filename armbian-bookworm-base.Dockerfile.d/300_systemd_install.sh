#!/bin/sh -eu
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

#set -x
. "$SRC/lib.sh"; init

chroot /target apt-get install -y \
  libnss-resolve systemd-resolved systemd-timesyncd

chroot /target \
  systemctl unmask systemd-networkd.service
chroot /target \
  systemctl enable systemd-networkd.service
rm -f \
  /target/etc/network/interfaces.default \
  /target/etc/network/interfaces.d/* \
# EO rm -f

chroot /target \
  systemctl unmask systemd-timesyncd.service
chroot /target \
  systemctl enable systemd-timesyncd.service

chroot /target \
  systemctl unmask systemd-resolved.service
chroot /target \
  systemctl enable systemd-resolved.service

rm -f \
  /target/etc/.resolv.conf.systemd-resolved.bak \
  /target/etc/resolv.conf-
ln -s /run/systemd/resolve/resolv.conf /target/etc/resolv.conf-

chroot /target \
  systemctl disable systemd-networkd-wait-online.service
chroot /target \
  systemctl mask systemd-networkd-wait-online.service

rm -f /target//etc/systemd/system/getty@.service.d/override.conf
rm -f /target//etc/systemd/system/serial-getty@.service.d/override.conf

chroot /target \
  systemctl enable etc-machine-id.service
rm -f /target/etc/machine-id
