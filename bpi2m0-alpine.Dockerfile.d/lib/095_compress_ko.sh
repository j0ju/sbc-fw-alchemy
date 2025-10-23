#!/bin/sh -eu
# - shell environment file for run-parts scripts in this directory
# (C) 2024-2025 Joerg Jungermann, GPLv2 see LICENSE
set -eu

PS4='> ${0##*/}: '
#set -x

umask 022

# chdir to current kernel modules dir / assume we have only one kernel installed
cd /target/lib/modules/[0-9]*

kver="${PWD##*/}"
find . -name "*.ko" -exec xz {} \;

chroot /target depmod -a "$kver"
