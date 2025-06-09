#!/bin/sh -eu
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

#set -x
. "$SRC/lib.sh"; init

cd /target/etc/pam.d/

sed -i -e "/pam_motd/ s/^/# /" \
  sshd login
