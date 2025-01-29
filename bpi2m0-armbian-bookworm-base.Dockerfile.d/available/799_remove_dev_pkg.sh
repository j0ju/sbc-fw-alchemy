#!/bin/sh -eu
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

#set -x
. "$SRC/lib.sh"; init

#- purge packages
  chroot /target apt-get remove --purge -y \
      build-essential \
      $(chroot /target dpkg -l *-dev | awk '$1 == "ii" && $2 ~ "-dev(:|$)" {print $2}')

  chroot /target apt-get autoremove --purge -y
