#!/bin/sh -eu
# (C) 2023-2025 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
set -eu
#set -x

chroot /target apt-get update
