#!/bin/sh -eu
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE
PS4='> ${0##*/}: '
set -eu

. "$SRC/lib.sh"; init
set -x

chroot "$DST" apt-get upgrade -y
chroot "$DST" apt-get dist-upgrade -y
