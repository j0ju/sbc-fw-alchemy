#!/bin/sh
# (C) 2025,2026 Joerg Jungermann, GPLv2 see LICENSE
set -eu
. "$SRC/lib.sh"; init

set -x # DEBUG

chroot "$DST" \
  dpkg -P \
    snapd gnome-software-plugin-snap \
    firefox thunderbird \
    #
