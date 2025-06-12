#!/bin/sh -eu
# (C) 2023-2025 Joerg Jungermann, GPLv2 see LICENSE

#set -x
. "$SRC/lib.sh"; init

#- prevent initial login dialog
  rm -f /target//root/.not_logged_in_yet

#- purge packages
  rm -rf /target/etc/netplan /target/etc/NetworkManager

  chroot /target apt-get remove --purge -y \
      zsh \
      command-not-found \
      expect tcl-expect tcl8.6 \
      avahi-autoipd \
      adwaita-icon-theme \
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
      alsa-utils libasound2 libasound2-data libatopology2 \
      $(chroot /target dpkg -l *-dev | awk '$1 == "ii" && $2 ~ "-dev(:|$)" {print $2}')

  chroot /target apt-get autoremove --purge -y
