#!/bin/sh
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE
set -eu
umask 022
PS4='> ${0##*/}: '
set -x

# example input:  SRC=/src/images/rpi-raspios-lite-base.Dockerfile.d set from Dockerfile.seed
# example output: SRC=/src/images/rpi64-raspios-lite-base.Dockerfile.d set from Dockerfile
src="${SRC%/*}"
dir="${SRC#$src/}"
export SRC="${src}/rpi64-${dir#rpi-}"

for sh in "$SRC"/[0-9]*.sh; do
  sh -eu "$sh"
done
