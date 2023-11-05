#!/bin/sh -eu
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
#set -x

mv /target /target.old
mv /target.old/part1 /target
mv /target.old/uboot.egn /target/boot/uboot.egn
rm -rf /target.old
tar cf - -C /dev . | tar xf - -C /target/dev
