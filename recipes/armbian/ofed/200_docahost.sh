#!/bin/sh -eu
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE
PS4='> ${0##*/}: '
set -eu

. "$SRC/lib.sh"; init
set -x

# this needs kernel enabled with
# * CONFIG_IRQPOLL
# * CONFIG_INFINIBAND
# * CONFIG_DYNAMIC_DEBUG


PKG="https://www.mellanox.com/downloads/DOCA/DOCA_v3.2.2/host/doca-host_3.2.2-035000-25.10-debian13_arm64.deb"

cd /target
#wget "$PKG"
PKG="${PKG##*/}"

chroot . dpkg -i "${PKG}"
chroot . apt-get update

#chroot . apt-get -y install doca-runtime
chroot . apt-get -y install doca-basic rshim
#chroot . apt-get -y install doca-networking

chroot . systemctl disable openibd opensmd || :
chroot . systemctl enable rshimd || :

chroot . apt-get clean
chroot . dpkg -P doca-host
chroot . rm -rf \
  /usr/share/doca-host* \
  /etc/systemd/system/basic.target.wants/live-config.service \
  /etc/systemd/system/rdma-hw.target.wants/ibacm.service \
  "${PKG}"
# EO rm -rf
