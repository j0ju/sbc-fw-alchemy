#!/bin/sh -eu
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

. "$SRC/lib.sh"; init

apt-get update
apt-get dist-upgrade -yd
apt-get upgrade -y
apt-get dist-upgrade -y

chroot /target sh /lib/cleanup-rootfs.sh
