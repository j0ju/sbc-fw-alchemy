#!/bin/sh -eu
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
#set -x

. "$SRC/lib.sh"; init
    
# no local console
  chroot /target \
    systemctl mask getty@.service
