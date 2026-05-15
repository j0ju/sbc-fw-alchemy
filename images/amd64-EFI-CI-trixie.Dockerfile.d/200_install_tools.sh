#!/bin/sh -eu
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE
PS4='> ${0##*/}: '
set -eu

. "$SRC/lib.sh"; init
set -x

chroot "$DST" \
  apt-get install -y \
    mc tmux screen vim-nox tcpdump mtr-tiny strace \
    lsof console-setup cifs-utils nfs-common pv ntfs-3g \
    ifupdown-ng ifupdown-ng-compat fastd bridge-utils \
    gdisk squashfs-tools mtools xorriso \
    grub-efi-amd64-bin grub-efi \
    diffutils \
    busybox udhcpc make \
    microcom minicom picocom \
    usbutils pciutils \
      libusb-1.0-0 \
    ifstat dnsmasq \
    ipmitool \
  #

mkdir -p "$DST"/etc/network/interfaces.d
