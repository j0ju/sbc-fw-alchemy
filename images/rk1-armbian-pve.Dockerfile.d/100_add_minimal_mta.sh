#!/bin/sh -eu
# (C) 2025-2026 Joerg Jungermann, GPLv2 see LICENSE
PS4='> ${0##*/}: '
set -eu
. "$SRC/lib.sh"; init
#set -x

#- install minimal MTA
if ! chroot "$DST" apt-get install -y --no-install-recommends ssmtp; then
  # deal with invalid hostname call in case of chroot in postinst script
  rm "$DST/var/lib/dpkg/info/ssmtp.postinst"
  chroot "$DST" apt-get install -f -y
fi
