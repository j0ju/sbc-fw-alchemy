#!/bin/sh
# (C) 2025,2026 Joerg Jungermann, GPLv2 see LICENSE
set -eu
umask 022

PS4='> ${0##*/}: '
set -x

PREFIX=/usr

mkdir -p /target/src
cd /target/src
git clone --recursive https://github.com/GustaKir/fbink-xdamage.git fbink-xdamage
cd fbink-xdamage

for i in "${0}.d"/[0-9]*.patch; do
  [ -f "$i" ] || continue
  patch -p1 < "$i"
done

chroot /target sh <<EOF
PS4="${PS4%: }::chroot"
set -eu
set -x
cd /src/fbink-xdamage
make
EOF

mkdir -p /target/usr/local/bin /target/usr/local/lib
cp -a \
  /target/src/fbink-xdamage/fbink_xdamage \
  /target/src/fbink-xdamage/FBInk/Release/fbink \
/target/$PREFIX/bin

cp -a \
  /target/src/fbink-xdamage/FBInk/Release/lib*.so \
  /target/src/fbink-xdamage/FBInk/Release/lib*.so.* \
/target/$PREFIX/lib

mv /target/src /target-src/

chroot /target sh <<EOF
PS4="${PS4%: }::chroot"
set -eu
cd /
set -x
apk del alpine-sdk
apk info | grep [-]dev | xargs apk del
rmdir * 2> /dev/null || :
EOF
