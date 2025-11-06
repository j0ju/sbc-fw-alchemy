#!/bin/sh -e
# (C) 2023-2025 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
#set -x

echo "I: update-rc"
  chroot /target /usr/local/sbin/update-rc
