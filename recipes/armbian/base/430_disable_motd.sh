#!/bin/sh -eu
# (C) 2023-2026 Joerg Jungermann, GPLv2 see LICENSE

#set -x
. "$SRC/lib.sh"; init

cd $DST/etc/pam.d/

sed -i -e "/pam_motd/ s/^/# /" \
  sshd login
