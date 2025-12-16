#!/bin/sh
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE
set -eu
umask 022

#- install bmcd into /target
  tar xf /turingpi2-alpine-rkdevelop.tar.zst -C /target
  ln -s ../../../opt/rockchip/bin/rkdeveloptool /target/usr/local/bin
