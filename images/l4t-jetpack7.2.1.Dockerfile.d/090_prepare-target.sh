#!/bin/sh
# (C) 2025-26 Joerg Jungermann, GPLv2 see LICENSE
set -eu
PS4='> ${0##*/}: '
umask 022

set -x # DEBUG

mkdir -p "$DST"/run/systemd/resolve/
cat /etc/resolv.conf | chroot /target sh -c "cat > /etc/resolv.conf"

cp -a  /dev/null /dev/*random /dev/tty /dev/zero "$DST/dev/"

chroot "$DST" apt-get update
