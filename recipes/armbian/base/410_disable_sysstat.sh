#!/bin/sh -eu
# (C) 2023-2026 Joerg Jungermann, GPLv2 see LICENSE

#set -x
. "$SRC/lib.sh"; init

sed -i -r \
    -e 's/^([0-9])/#\1/' \
  $DST/etc/cron.d/sysstat

DISABLE=
DISABLE="$DISABLE sysstat-collect.service sysstat-collect.timer"

chroot ${DST:-/} systemctl disable $DISABLE
chroot ${DST:-/} systemctl mask $DISABLE
