#!/bin/sh
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE
set -eu

chroot /target apk add raspberrypi-utils

rm -f /target/etc/.git/HEAD.lock
