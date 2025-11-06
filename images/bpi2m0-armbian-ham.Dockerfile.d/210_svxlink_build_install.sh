#!/bin/sh -eu
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE

# * this builds and installs svxlink
# * leaves the source for later updates and changes in PREFIX/src
# * PREFIX is defined in 200_svxlink_config.sh

. "$SRC/lib.sh"; init
#set -x

. ${0%/*}/200_svxlink_config.sh

chroot /target /bin/sh -eu << EOF
  #set -x
  umask 022

  # create prefix
  mkdir -p "$PREFIX"/src

  # checkout specific version via tag
  git clone https://github.com/sm0svx/svxlink.git "$PREFIX/src/svxlink-git"
  cd "$PREFIX/src/svxlink-git"
  git co -b v$TAG $TAG

  # prepare directory and build
  mkdir -p ../svxlink-build
  cd  ../svxlink-build
  cmake -DCMAKE_INSTALL_PREFIX="$PREFIX" -DSYSCONF_INSTALL_DIR=/etc -DLOCAL_STATE_DIR=/var -DUSE_QT=NO -DWITH_SYSTEMD=yes ../svxlink-git/src
  make -j all doc

  # install
  make install
EOF
