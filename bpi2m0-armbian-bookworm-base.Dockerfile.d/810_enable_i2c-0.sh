#!/bin/sh -eu
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

. "$SRC/lib.sh"; init

OVERLAYS=
OVERLAYS="$OVERLAYS i2c0"
#OVERLAYS="$OVERLAYS w1-gpio"

if ! grep ^overlays= /target/boot/armbianEnv.txt > /dev/null; then
  echo overlays= >> /target/boot/armbianEnv.txt
fi

for o in $OVERLAYS; do
  sed -i -r -e 's/^overlays=.*/\0 '"$o"'/' /target/boot/armbianEnv.txt 
done
