#!/bin/sh
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE
umask 022
PS4="> ${0##*/}: "

set -x

#- as I am running as UID=0 in container, but with thumb screws (seccomp, no capabilities)
# TODO: maybe move add "-u $(id -u):$(id -g)" to bin/img-mangler and bin/IRun
export FORCE_UNSAFE_CONFIGURE=1

# FIXME: move compiler cache from /root/ to /workspace
# /root is volatile
cd /workspace

if [ -d bmc-firmware ]; then
  cd bmc-firmware/buildroot
  make
else :
  git clone https://github.com/turing-machines/BMC-Firmware.git bmc-firmware
  cd bmc-firmware

  #- patch kernel config
  cp "${0%/*}"/linux_defconfig  tp2bmc/board/tp2bmc/linux_defconfig
  cp "${0%/*}"/tp2bmc_defconfig tp2bmc/configs/tp2bmc_defconfig

  #- prepare /workspace/bmc-firmware/buildroot
  ./scripts/configure.sh
  ./scripts/build.sh
fi

mkdir -p /src/input/turingpi2-buildroot
# fix permissions if container UID != host UID
[ -z "$OWNER" ] || \
  chown -R "$OWNER${GROUP:+:$GROUP}" /src/input/turingpi2-buildroot
cp /workspace/bmc-firmware/buildroot/output/images/rootfs.tar                /src/input/turingpi2-buildroot
cp /workspace/bmc-firmware/buildroot/output/images/u-boot-sunxi-with-spl.bin /src/input/turingpi2-buildroot/uboot.img

# fix permissions if container UID != host UID
[ -z "$OWNER" ] || \
  chown -R "$OWNER${GROUP:+:$GROUP}" /workspace/bmc-firmware/buildroot/output/images/.
