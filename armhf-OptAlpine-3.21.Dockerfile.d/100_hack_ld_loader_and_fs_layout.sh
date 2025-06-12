#!/bin/sh -e
# (C) 2023-2025 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
#set -x

SRC=/lib/ld-musl-armhf.so.1
NEW_LIBPATH=/opt/alpine/lib
OUTPUT_DIR=/tarballs

ORIGIN_LIBPATH="$(strings "$SRC"  | grep ^/lib:)"
NEEDLE="^/lib:$(echo -n ${NEW_LIBPATH#?????} | tr 'a-zA-Z0-9/:-' '.' )."
REGEX="s|$NEEDLE|$NEW_LIBPATH"'\x0'"|"
DST="/opt/alpine/lib/${SRC##*/}"

echo "I: patch ld.so"
  mkdir -p "${NEW_LIBPATH%/*}"
  # test files
  strings  "$SRC" | tee "/${SRC##*/}".orig.strings | sed    -r -e "$REGEX" > "/${SRC##*/}".strings
  # actual patch
  cat      "$SRC" | tee "/${SRC##*/}".orig         | sed -z -r -e "$REGEX" > "/${SRC##*/}"
  chmod 0755 "/${SRC##*/}"

echo "I: prepare substitution ld.so"
  # usr-merge
  cp -a /usr/lib "${NEW_LIBPATH%/*}"
  # take some special care because of dangling symlinks
  #rm -f \
  # EO rm -f

  cp -a /lib     "${NEW_LIBPATH%/*}"
  mv "/${SRC##*/}" "$DST"
  mv "/${SRC##*/}"* "$NEW_LIBPATH"

  ln -sf "$DST" "/lib/${SRC##*/}"
  rm -rf /lib /usr/lib
  $DST /bin/busybox ln -s "${NEW_LIBPATH}" /usr/lib
  $DST /bin/busybox ln -s "${NEW_LIBPATH}" /lib
