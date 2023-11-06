#!/bin/sh -eu
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
#set -x

cp /lib/cleanup-rootfs.sh /target/lib/cleanup-rootfs.sh
cp /etc/resolv.conf /target/etc/resolv.conf
