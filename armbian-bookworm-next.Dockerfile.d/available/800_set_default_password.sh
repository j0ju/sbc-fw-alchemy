#!/bin/sh -e
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
#set -x

echo root:root | chroot /target chpasswd
