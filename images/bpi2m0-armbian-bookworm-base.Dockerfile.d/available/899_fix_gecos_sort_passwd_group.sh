#!/bin/sh -eu
# (C) 2023-2025 Joerg Jungermann, GPLv2 see LICENSE

. "$SRC/lib.sh"; init
#set -x

sed -i -e s/,,,// /target/etc/passwd
chroot /target pwck -s
chroot /target grpck -s
