#!/bin/sh -e
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
#set -x

  mv /target/usr/sbin/invoke-rc.d /target/usr/sbin/invoke-rc.d.dist
    ln -s /bin/true /target/usr/sbin/invoke-rc.d
      chroot /target apt-get dist-upgrade -y
    rm -f /target/usr/sbin/invoke-rc.d
  mv /target/usr/sbin/invoke-rc.d.dist /target/usr/sbin/invoke-rc.d
