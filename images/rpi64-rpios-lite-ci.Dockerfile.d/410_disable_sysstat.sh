#!/bin/sh -eu
# (C) 2023-2025 Joerg Jungermann, GPLv2 see LICENSE

#set -x
. "$SRC/lib.sh"; init

sed -i -r \
    -e 's/^([0-9])/#\1/' \
  /target/etc/cron.d/sysstat

DISABLE=
DISABLE="$DISABLE sysstat-collect.service sysstat-collect.timer"

chroot /target systemctl disable $DISABLE
chroot /target systemctl mask $DISABLE
