#!/bin/sh -eu
# (C) 2023-2025 Joerg Jungermann, GPLv2 see LICENSE

. "$SRC/lib.sh"; init

PS4='> ${0##*/}: '
set -eu
#set -x

chroot /target apt-get clean
if ls /prefetch.deb/*.deb > /dev/null 2>&1; then
    mv /prefetch.deb/*.deb /target/var/cache/apt/archives
    chroot /target sh -euc '
        cd /var/cache/apt/archives
        dpkg -i *.deb
        rm -f *.deb
        apt-get clean
    '
fi
