#!/bin/sh -eu
# (C) 2023-2025 Joerg Jungermann, GPLv2 see LICENSE

. "$SRC/lib.sh"; init
#set -x

rm -f \
  /target/etc/profile.d/wifi-check.sh \
  /target/etc/profile.d/sshpwd.sh \
  /target/etc/issue.d/* \
  /target/boot/cmdline.txt \
  /target/boot/config.txt \
  /target/boot/issue.txt \
# EO rm -f
