#!/bin/sh
# (C) 2023-2026 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
set -eu
#set -x

# upgrade to latest backports kernel
#apt-get install -t trixie-backports -y \
#  linux-image-amd64 \
#  linux-headers-amd64 \
#

# remove all but latest kernel before continueing with DKMS foo
# apt-cache depends linux-image-amd64
#  ( cd /var/lib/dpkg/info/; ls linux-image*.list linux-headers*.list ) | sed -re 's/[.][^.]+$//' | sort -u
