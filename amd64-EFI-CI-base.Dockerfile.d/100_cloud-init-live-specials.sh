#!/bin/sh -eu
# (C) 2023-2025 Joerg Jungermann, GPLv2 see LICENSE

. "$SRC/lib.sh"; init

PS4='> ${0##*/}: '
set -eu
#set -x

# do not run network detection and ds-identify
chroot /target systemctl disable cloud-init-local

chroot /target systemctl enable cloud-init cloud-final
