#!/bin/sh -e
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
#set -x

cd /target/boot

rm -f \
  armbian_first_run.txt \
  armbian_first_run.txt.template \
  uInitrd* \
# EO rm -f
