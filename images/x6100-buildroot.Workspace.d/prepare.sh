#!/bin/sh
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE
umask 022
PS4="> ${0##*/}: "
set -x

#- as I am running as UID=0 in container, but with thumb screws (seccomp, no capabilities)
  export FORCE_UNSAFE_CONFIGURE=1

#- !!!! /root is volatile, home is moved via img-wangler/IRun
  cd /workspace

  mkdir -p /workspace/x6100

  if ! [ -d AetherX6100Buildroot/.git ]; then
    git clone https://github.com/gdyuldin/AetherX6100Buildroot
  fi

  if ! [ -d x6100_gui ]; then
    git clone https://github.com/gdyuldin/x6100_gui
  fi

  ( cd AetherX6100Buildroot
    git submodule init
    git submodule update
    ./br_config.sh
    cd build
    make
  )

  ( cd x6100_gui
    git submodule init
    git submodule update

    cd buildroot
    ./build.sh
  )

#- prepare rootfile system tarball for import
  TARGET=/src/input/x6100-buildroot.tar
  cp /workspace/AetherX6100Buildroot/build/images/rootfs.tar "$TARGET"
  cp /workspace/AetherX6100Buildroot/build/images/u-boot-sunxi-with-spl.bin /workspace/AetherX6100Buildroot/build/images/uboot.img
  rm -f /workspace/AetherX6100Buildroot/build/images/boot 
  ln -s . /workspace/AetherX6100Buildroot/build/images/boot
  tar --append --file "$TARGET" -h -C /workspace/AetherX6100Buildroot/build/images ./boot/uboot.img

#- fix permissions if container UID != host UID
  [ -z "$OWNER" ] || \
    chown -R "$OWNER${GROUP:+:$GROUP}" "$TARGET"
