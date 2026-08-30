#!/bin/sh
# (C) 2025,2026 Joerg Jungermann, GPLv2 see LICENSE
set -eu
umask 022
. "$SRC/lib.sh"; init

set -x

chroot "$DST" \
  dpkg -P \
    rsyslog \
  #
#
