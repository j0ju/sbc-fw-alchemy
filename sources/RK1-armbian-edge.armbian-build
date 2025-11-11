#!/bin/sh

# script to build Armbian/Trixie image with latest kernel using compile.sh
# see https://github.com/armbian/build
set -x
./compile.sh \
  BOARD=turing-rk1 \
  BRANCH=edge \
  RELEASE=trixie \
  BUILD_MINIMAL=yes \
  KERNEL_CONFIGURE=no \
  INSTALL_HEADERS=yes \
  ENABLE_EXTENSIONS="cloud-init rkbin-tools fs-btrfs-support fs-f2fs-support fs-xfs-support" \
  #
