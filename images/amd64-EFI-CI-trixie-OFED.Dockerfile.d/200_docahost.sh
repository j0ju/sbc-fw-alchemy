#!/bin/sh -eu
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE
PS4='> ${0##*/}: '
set -eu

. "$SRC/lib.sh"; init
set -x

cd "$DST"
#wget "$PKG"

sudo dpkg -i *.deb
rm *.deb

apt-get update

#apt-get -y install doca-runtime
#apt-get -y install doca-networking

apt-get -y install \
  doca-basic \
  doca-installer \
  mlnx-ofed-kernel-dkms \
  rshim \
  mft mft-mlx5 mft-nvredfish kernel-mft-dkms \
#

# add some benchmarking tools
export DEBIAN_FRONTEND=noninteractive
apt-get install -y \
  iperf iperf3 frr \
# EO apt-get

for svc in openibd opensmd ibacm rshim iperf iperf3 frr; do
  systemctl disable $svc || :
done

apt-get clean
dpkg -P doca-host
rm -rf \
  /usr/share/doca-host* \
  /etc/systemd/system/rdma-hw.target.wants/ibacm.service \
# EO rm -rf
