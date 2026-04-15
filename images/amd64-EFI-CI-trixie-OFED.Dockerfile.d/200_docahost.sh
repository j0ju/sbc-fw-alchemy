#!/bin/sh -eu
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE
PS4='> ${0##*/}: '
set -eu

. "$SRC/lib.sh"; init
set -x

PKG="https://www.mellanox.com/downloads/DOCA/DOCA_v3.2.2/host/doca-host_3.2.2-035000-25.10-debian13_amd64.deb"

cd "$DST"
wget "$PKG"
PKG="${PKG##*/}"

sudo dpkg -i "$PKG"

sudo apt-get update
sudo apt-get -y install doca-networking

# add some benchmarking tools
export DEBIAN_FRONTEND=noninteractive
apt-get install -y \
  iperf iperf3 \
# EO apt-get

systemctl disable openibd opensmd ibacm || :
systemctl enable rshimd || :

apt-get clean
dpkg -P doca-host
rm -rf \
  /usr/share/doca-host* \
  /etc/systemd/system/rdma-hw.target.wants/ibacm.service \
  "$PKG" \
# EO rm -rf
