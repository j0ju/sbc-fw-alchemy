#!/bin/sh -eu
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

. "$SRC/lib.sh"; init
chroot /target apt-get clean

( cd /target/home/birdnet
  rm -f \
    install-birdnet.sh \
    installation-2025-03-07.txt \
  # EOrm-f
)

rm -f /target/etc/systemd/system/multi-user.target.wants/avahi-alias@*.service
chroot /target/ systemctl enable \
  avahi-daemon.service \
  avahi-alias@birdnet.local.service \
# EOchroot-systemctl

