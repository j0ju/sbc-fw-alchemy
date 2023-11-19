#!/bin/sh -eu
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
set -x

chroot /target useradd -m -u 314 -g 100 pi
echo pi:raspberry | chroot /target chpasswd
