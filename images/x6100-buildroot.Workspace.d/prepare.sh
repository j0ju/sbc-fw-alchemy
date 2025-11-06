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

# FIXME:
## fix permissions if container UID != host UID
#[ -z "$OWNER" ] || \
#  chown -R "$OWNER${GROUP:+:$GROUP}" /workspace/bmc-firmware/buildroot/output/images/.
