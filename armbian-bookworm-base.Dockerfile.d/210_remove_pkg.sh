#!/bin/sh -eu
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
#set -x

. "$SRC/lib.sh"; init

#- prevent initial login dialog
  rm -f /target//root/.not_logged_in_yet

#- purge packages
  chroot /target /bin/sh /var/lib/dpkg/info/nfs-common.postrm purge
  chroot /target etckeeper commit -m "nfs-common: pre-removal"

  rm /target/var/lib/dpkg/info/nfs-common.postrm
  rm -rf /target/etc/netplan /target/etc/NetworkManager

  mv /target/usr/sbin/invoke-rc.d /target/usr/sbin/invoke-rc.d.dist
    ln -s /bin/true /target/usr/sbin/invoke-rc.d
    chroot /target apt-get remove --purge -y \
      zsh armbian-zsh \
      command-not-found \
      expect tcl-expect tcl8.6 \
      avahi-autoipd \
      adwaita-icon-theme \
      armbian-plymouth-theme \
      rsyslog rpcbind nfs-common \
      f3 smartmontools stress \
      toilet \
      qrencode \
      plymouth \
      openvpn \
      pciutils \
      man-db \
      iperf3 iozone3 \
      flex bison binutils \
      chrony \
      apt-file \
      btrfs-progs \
      vnstat \
      parted \
      figlet \
      fbset \
      html2text \
      network-manager netplan.io \
      ntfs-3g \
      nano \
      $(chroot /target dpkg -l *-dev | awk '$1 == "ii" && $2 ~ "-dev(:|$)" {print $2}')

  chroot /target apt-get autoremove --purge -y
