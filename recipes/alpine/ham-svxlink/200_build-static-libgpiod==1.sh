#!/bin/sh -eu
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE

# * this builds and installs libgpiod 1.63 statically for svxlink 25.05
# * leaves the source for later updates and changes in PREFIX/src
# * PREFIX is defined in 200_svxlink_config.sh

. ${0%/*}/000_recipe_svxlink_config.sh

PREFIX=/usr
NCPU=$(cat /proc/cpuinfo | grep -c ^processor) || NCPU=2

chroot /target /bin/sh -eu << EOF
  PS4="${PS4%: }::chroot: "
  set -x
  umask 022

  # create prefix
  mkdir -p "$PREFIX"/src
  cd "$PREFIX"/src

  wget http://deb.debian.org/debian/pool/main/libg/libgpiod/libgpiod_1.6.3.orig.tar.xz
  tar xf libgpiod_1.6.3.orig.tar.xz || tar xf libgpiod_1.6.3.orig.tar.xz
  cd libgpiod-1.6.3

  autoupdate
  aclocal
  autoreconf -f
  automake
  ./configure --prefix=$PREFIX --enable-tools --enable-static --disable-shared
  make -j$NCPU
  make install

  rm -rf /usr/src/libgpiod*
EOF
