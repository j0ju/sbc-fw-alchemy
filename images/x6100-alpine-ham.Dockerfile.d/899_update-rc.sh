#!/bin/sh
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE
set -eu

PS4='> ${0##*/}: '
#set -x

# enable basic services
chroot /target /bin/sh > /dev/null -e <<EOF
PS4='> ${PS4%: }:chroot: '
#set -x

/usr/local/sbin/update-rc 1> /dev/null
EOF
