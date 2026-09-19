#!/bin/sh -eu
# (C) 2023-2026 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
set -eu
#set -x

cp -a /lib/cleanup-rootfs.sh /target/lib/cleanup-rootfs.sh
