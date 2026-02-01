#!/bin/sh -e
# - shell environment file for run-parts scripts in this directory
# (C) 2024-2026 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
#set -x

# install packages for tarballs
  chroot /target apk upgrade

