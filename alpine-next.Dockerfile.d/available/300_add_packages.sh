#!/bin/sh -eu
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
#set -x

chroot /target /sbin/apk add --no-cache \
  man-db \
# EO chroot apk add
