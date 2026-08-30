#!/bin/sh
# (C) 2025-26 Joerg Jungermann, GPLv2 see LICENSE
set -eu
PS4='> ${0##*/}: '
umask 022

set -x # DEBUG

# put DTB to subdir
mkdir -p \
  "$DST/boot/dtb" \
  "$DST/boot/overlay-user" \
  #
mv "$DST/boot"/*.dtb* "$DST/boot/dtb"

FSDIR="$0.d"
cp "$FSDIR"/Makefile "$DST/boot/dtb"
( cd "$DST/boot/dtb"
  make dts
)

ln -s ../dtb/Makefile "$DST/boot/overlay-user"
