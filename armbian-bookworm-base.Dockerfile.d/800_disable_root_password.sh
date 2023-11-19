#!/bin/sh -eu
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
#set -x

sed -i -r -e 's/^root:[^:]+:/root:x:/' /etc/passwd
