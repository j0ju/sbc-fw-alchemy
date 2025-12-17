#!/bin/sh
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE
set -eu
umask 022

#- install bmcd into /target
  tar xf /turingpi2-alpine-rpiboot.tar.zst -C /target
  ln -s ../../../opt/rpiboot/bin/rpiboot /target/usr/local/bin
