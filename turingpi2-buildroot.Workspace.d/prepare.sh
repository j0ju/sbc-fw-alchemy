#!/bin/sh
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE
set -eu
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
  #echo "E: already checked out, clean manually or do make clean-volumes"
  #exit 1
else :
  git clone https://github.com/turing-machines/BMC-Firmware.git bmc-firmware
  cd bmc-firmware

  #- patch kernel config
  cp "${0%/*}"/linux_defconfig  tp2bmc/board/tp2bmc/linux_defconfig

  #- prepare /workspace/bmc-firmware/buildroot
  ./scripts/configure.sh

  #- link image output to ./output
  mkdir -p /src/input/turingpi2-buildroot
  mkdir -p /workspace/bmc-firmware/buildroot/output
  [ -z "$OWNER" ] || \
    chown -R "$OWNER${GROUP:+:$GROUP}" /src/input/turingpi2-buildroot /workspace/bmc-firmware/buildroot/output
  rm -rf /workspace/bmc-firmware/buildroot/output/images
  ln -s /src/input/turingpi2-buildroot /workspace/bmc-firmware/buildroot/output/images

  ./scripts/build.sh
fi

# fix permissions if container UID != host UID
[ -z "$OWNER" ] || \
  chown -R "$OWNER${GROUP:+:$GROUP}" /workspace/bmc-firmware/buildroot/output/images/.
