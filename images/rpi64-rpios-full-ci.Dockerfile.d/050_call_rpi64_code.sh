#!/bin/sh
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE
set -eu
umask 022
PS4='> ${0##*/}: '
set -x

export SRC=/src/images/rpi64-rpios-lite-ci.Dockerfile.d
for sh in "$SRC"/[0-9]*.sh; do
  sh -eu "$sh"
done
