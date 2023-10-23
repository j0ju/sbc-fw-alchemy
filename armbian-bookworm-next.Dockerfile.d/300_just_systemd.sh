#!/bin/sh -e
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
#set -x

mv /target/usr/sbin/invoke-rc.d /target/usr/sbin/invoke-rc.d.dist
  ln -s /bin/true /target/usr/sbin/invoke-rc.d
    chroot /target apt-get install -y \
      libnss-resolve systemd-resolved systemd-timesyncd

    chroot /target \
      systemctl unmask systemd-networkd
    
    chroot /target \
      systemctl enable systemd-networkd

    chroot /target \
      systemctl enable systemd-timesyncd

    chroot /target \
      systemctl enable systemd-resolved

  rm -f /target/usr/sbin/invoke-rc.d
mv /target/usr/sbin/invoke-rc.d.dist /target/usr/sbin/invoke-rc.d
