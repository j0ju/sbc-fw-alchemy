#!/bin/sh -e
# - shell environment file for run-parts scripts in this directory
# (C) 2024-2026 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
#set -x
#
umask 022

# prepare a local minimal /dev and resolv.conf
cp -a /dev/* /target/dev
rm -f /target/etc/resolv.conf
cp /etc/resolv.conf /target/etc/resolv.conf
