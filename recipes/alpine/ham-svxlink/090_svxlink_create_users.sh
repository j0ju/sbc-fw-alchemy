#!/bin/sh -eu
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE

# * this builds and installs svxlink
# * leaves the source for later updates and changes in PREFIX/src
# * PREFIX is defined in 200_svxlink_config.sh

. ${0%/*}/000_recipe_svxlink_config.sh

chroot /target /bin/sh -eu << EOF
  PS4="${PS4%: }::chroot: "
  set -x
  umask 022

  getent group gpio 2> /dev/null 1>&2 || \
  addgroup --system gpio

  groupadd -g 73 -r svxlink
  useradd svxlink -g 73 -M -r -u 73

  usermod -a -G gpio svxlink
  usermod -a -G audio svxlink
EOF
