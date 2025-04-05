#!/bin/sh -e
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
set -x

mv /target /target.old ;\
mv /target.old/part2 /target ;\
cp -a /target.old/part1/* /target/boot ;\
cp /target.old/uboot.egn /target/boot ;\
rm -rf /target.old ;\
