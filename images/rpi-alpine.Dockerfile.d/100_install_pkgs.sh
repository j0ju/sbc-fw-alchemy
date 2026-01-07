#!/bin/sh
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE
set -eu

# add some directories needed for operation
mkdir -p /target/tmp/cache/apk /target/tmp/cache/etckeeper

chroot /target apk add \
  raspberrypi-utils btrfs-progs rdnssd rsync pciutils

rm -f /target/etc/.git/HEAD.lock
