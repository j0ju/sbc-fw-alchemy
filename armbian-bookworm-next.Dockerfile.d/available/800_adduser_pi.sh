#!/bin/sh -eu
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

. "$SRC/lib.sh"; init
PS4='> ${0##*/}: '
#set -x

chroot /target useradd -m -u 963 -g 100 -s /bin/bash pi
chroot /target adduser pi sudo
echo pi:raspberry | chroot /target chpasswd
