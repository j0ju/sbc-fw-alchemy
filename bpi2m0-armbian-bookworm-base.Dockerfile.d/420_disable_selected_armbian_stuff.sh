#!/bin/sh -eu
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

#set -x
. "$SRC/lib.sh"; init

DISABLE=

#DISABLE="$DISABLE armbian-resize-filesystem.service"
DISABLE="$DISABLE armbian-zram-config.service"
DISABLE="$DISABLE armbian-ramlog.service"

#DISABLE="$DISABLE armbian-led-state.service"
#DISABLE="$DISABLE armbian-hardware-optimize.service"
DISABLE="$DISABLE armbian-hardware-monitor.service"

DISABLE="$DISABLE armbian-firstrun.service"
DISABLE="$DISABLE armbian-firstrun-config.service"
rm -f \
  /target/boot/armbian_first_run.txt.template \
  /target/boot/armbian_first_run.txt \
# EO rm -f

DISABLE="$DISABLE armbian-disable-autologin.timer"
DISABLE="$DISABLE armbian-disable-autologin.service"

DISABLE="$DISABLE bootsplash-show-on-shutdown.service"
DISABLE="$DISABLE bootsplash-hide-when-booted.service"
DISABLE="$DISABLE bootsplash-ask-password-console.service"
DISABLE="$DISABLE bootsplash-ask-password-console.path"

chroot /target systemctl disable $DISABLE || :
chroot /target systemctl mask $DISABLE

sed -i -r -e 's/^[^#]/#\0/' \
  /target/etc/apt/apt.conf.d/02-armbian-p*update \
  /target/etc/cron.*/armbian-* \
  /target/etc/update-motd.d/* \
  /target/etc/profile.d/armbian-* \
# EO sed
