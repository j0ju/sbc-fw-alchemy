#!/bin/sh
set -eu
cd /workspace

git clone https://github.com/turing-machines/BMC-Firmware.git bmc-firmware
cd bmc-firmware
bash setup_build.sh

cd buildroot
make BR2_EXTERNAL=../tp2bmc tp2bmc_defconfig

#- actual build
#make
