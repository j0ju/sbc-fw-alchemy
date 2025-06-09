#!/bin/sh -eu
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
set -eu
#set -x

mv /target /import
mv /import/part2/ /target
tar cf - -C /import/part1/ . | tar xf - -C /target/boot/firmware/
tar cf - -C /dev . | tar xf - -C /target/dev
