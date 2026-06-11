#!/bin/sh
# (C) 2025,2026 Joerg Jungermann, GPLv2 see LICENSE
set -eu
umask 022

PS4='> ${0##*/}: '
set -x

chroot /target \
  apk add \
    fluxbox xeyes xorg-server
