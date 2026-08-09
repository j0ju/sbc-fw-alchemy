#!/bin/sh -eu
# (C) 2025-2026 Joerg Jungermann, GPLv2 see LICENSE
PS4='> ${0##*/}: '
set -eu
. "$SRC/lib.sh"; init
#set -x

#- install and support tools
chroot "$DST" apt-get install -y --no-install-recommends \
  skopeo open-iscsi \
# EO chroot
