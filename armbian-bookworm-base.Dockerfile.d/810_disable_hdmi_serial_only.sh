#!/bin/sh -eu
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

# this saves around 50mA in idle

. "$SRC/lib.sh"; init
. "$SRC/100_add_files.sh"

rm -f /target/etc/systemd/system/getty@.service.d/override.conf
rm -f /target/etc/systemd/system/serial-getty@.service.d/override.conf

SHOPTS="$(echo $- | tr -cd 'eux')"
chroot /target /bin/sh -$SHOPTS <<EOF
  PS4="${PS4% }:chroot: "

  systemctl disable getty@.service
  systemctl mask getty@.service

  systemctl unmask serial-getty@.service
  systemctl enable serial-getty@ttyS0.service
  systemctl enable serial-getty@ttyGS0.service

  cd /boot/overlay-user
  make
  make enable
EOF

sed -i -r \
  -e '/^earlycon=.*$/ d ' \
  -e '/^console=.*$/ d ' \
  -e '/^docker_optimization=.*$/ d ' \
  -e '$a'"earlycon=on" \
  -e '$a'"console=serial" \
  -e '$a'"docker_optimization=off" \
/target/boot/armbianEnv.txt
