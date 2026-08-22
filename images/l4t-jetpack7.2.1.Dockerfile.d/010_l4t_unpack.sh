#!/bin/sh
# (C) 2026 Joerg Jungermann, GPLv2 see LICENSE
set -eu
PS4='> ${0##*/}: '
umask 022

set -x # DEBUG

rm -rf /Linux_for_Tegra/rootfs
mv /target /Linux_for_Tegra/rootfs
ln -s /Linux_for_Tegra/rootfs /target

echo DISTRIB_RELEASE=2404 > /etc/lsb-release ;: "fake lsb-release for L4t" ;\
apt-get update
apt-get install -y sudo

cd /Linux_for_Tegra
./tools/l4t_flash_prerequisites.sh

# patch missing eeprom for Turing RK1
sed -i -e 's/cvb_eeprom_read_size = <0x100>/cvb_eeprom_read_size = <0x0>/g' ./bootloader/generic/BCT/tegra234-mb2-bct-misc-p3767-0000.dts

./apply_binaries.sh
