#!/bin/sh -eu
# (C) 2023-2026 Joerg Jungermann, GPLv2 see LICENSE

#set -x
. "$SRC/lib.sh"; init

( cd $DST/etc/pam.d/
  sed -i -e "/pam_motd/ s/^/# /" \
    sshd login
)

rm -f \
  "$DST"/etc/cron.daily/armbian-quotes \
  "$DST"/etc/cron.daily/armbian-ram-logging \
  "$DST"/etc/cron.d/armbian-check-battery \
# EO rm -f
