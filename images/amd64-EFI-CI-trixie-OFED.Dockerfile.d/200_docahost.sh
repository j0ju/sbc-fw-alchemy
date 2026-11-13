#!/bin/sh -eu
# (C) 2025-2026 Joerg Jungermann, GPLv2 see LICENSE
PS4='> ${0##*/}: '
set -eu

. "$SRC/lib.sh"; init
set -x

cd "$DST"
#wget "$PKG"

sudo dpkg -i *.deb
rm *.deb

apt-get update

# DKMS postinst scripts build for ${KVERSION:-$(uname -r)}, but in a container
# uname -r is the host kernel, so point them at the image kernel
KVERSION="$(ls /lib/modules | sort -V | tail -n1)"
export KVERSION

# kernel specific DKMS patches: $SRC/<module>-<version>-<kernelversion>.patch
# dkms reads /etc/dkms/<module>-<version>-<kernelversion>.conf after the
# module's dkms.conf and applies PATCH[] from <build_dir>/patches/ with -p1
for p in "$SRC"/*-"$KVERSION".patch; do
  [ -e "$p" ] || continue
  n="${p##*/}"
  mvk="${n%.patch}"
  d="${mvk%-"$KVERSION"}"
  install -D -m 644 "$p" "/usr/src/$n"
  install -d "/usr/src/$d/patches"
  ln -sf "/usr/src/$n" "/usr/src/$d/patches/$n"
  printf 'PATCH[0]="%s"\n' "$n" > "/etc/dkms/$mvk.conf"
done

# the big packages
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
