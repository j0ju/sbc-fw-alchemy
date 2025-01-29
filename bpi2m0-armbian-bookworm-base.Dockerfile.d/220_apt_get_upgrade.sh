#!/bin/sh -eu
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

#set -x
. "$SRC/lib.sh"; init


chroot /target apt-get dist-upgrade -y
