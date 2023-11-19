#!/bin/sh -eu
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
#set -x

sed -i -e s/,,,// /target/etc/passwd
chroot /target pwck -s
chroot /target grpck -s
