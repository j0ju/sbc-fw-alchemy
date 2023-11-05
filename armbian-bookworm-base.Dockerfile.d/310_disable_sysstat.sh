#!/bin/sh -eu
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
#set -x

sed -i -r \
    -e 's/^([0-9])/#\1/' \
  /target/etc/cron.d/sysstat

DISABLE=
DISABLE="$DISABLE sysstat-collect.service sysstat-collect.timer"

chroot /target systemctl disable $DISABLE
chroot /target systemctl mask $DISABLE
