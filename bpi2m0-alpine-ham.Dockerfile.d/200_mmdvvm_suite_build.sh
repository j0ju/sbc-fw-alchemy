#!/bin/sh -eu
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE
set -eu
umask 022
set -x
PS4="> ${0##*/}: "

. ${0%/*}/000_mmdvm_config.sh

for repo in $REPOS; do
  project="${repo##*/}"
  project="${project%.git}"
chroot /target /bin/sh <<EOchroot
  umask 022
  PS4="${PS4%: }::chroot::$project: "
  set -x

  mkdir -p $PREFIX/bin $PREFIX/src
  cd "$PREFIX/src"
  git clone "$repo"
  cd "$project"
  make -j$NCPU
EOchroot
done
