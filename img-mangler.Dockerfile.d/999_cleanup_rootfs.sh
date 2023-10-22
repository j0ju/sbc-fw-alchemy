#!/bin/sh -e
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
#set -x

chroot "$DST" /bin/sh /lib/cleanup-rootfs.sh
