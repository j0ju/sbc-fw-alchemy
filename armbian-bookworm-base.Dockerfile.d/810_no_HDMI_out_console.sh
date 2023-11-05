#!/bin/sh -eu
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
#set -x
    
# no local console
  chroot /target \
    systemctl mask getty@.service
