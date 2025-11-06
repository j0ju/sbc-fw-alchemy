#!/bin/sh
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE
set -eu

# Input: SRC=/src/rpi-raspios-lite-base.Dockerfile.d set from Dockerfile
set -x
src="${SRC%/*}"
dir="${SRC#$src/}"
export SRC="${src}/rpi64-${dir#rpi-}"

for sh in "$SRC"/[0-9]*.sh; do
  sh "$sh"
done
