#!/bin/sh -eu
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

. "$SRC/lib.sh"; init
PS4='> ${0##*/}: '
#set -x

chroot /target apt-get install -y \
  python3-pip \
  python3-smbus python3-smbus2

umask 022

chroot /target pip3 install --break-system-packages -U pip
chroot /target pip3 install --break-system-packages    RPi.bme280
