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
  cp "${0%/*}"/uboot_defconfig  tp2bmc/board/tp2bmc/uboot_defconfig
  cp "${0%/*}"/tp2bmc_defconfig tp2bmc/configs/tp2bmc_defconfig

  #- prepare /workspace/bmc-firmware/buildroot
  ./scripts/configure.sh
  ./scripts/build.sh
fi

TARGET=/src/input/turingpi2-buildroot.tar

cp /workspace/bmc-firmware/buildroot/output/images/rootfs.tar "$TARGET"
cp /workspace/bmc-firmware/buildroot/output/images/u-boot-sunxi-with-spl.bin /workspace/bmc-firmware/buildroot/output/images/uboot.img
rm -f /workspace/bmc-firmware/buildroot/output/images/boot
ln -s . /workspace/bmc-firmware/buildroot/output/images/boot
tar --append --file $TARGET -h -C /workspace/bmc-firmware/buildroot/output/images ./boot/uboot.img ;\

# fix permissions if container UID != host UID
[ -z "$OWNER" ] || \
  chown -R "$OWNER${GROUP:+:$GROUP}" "$TARGET"
