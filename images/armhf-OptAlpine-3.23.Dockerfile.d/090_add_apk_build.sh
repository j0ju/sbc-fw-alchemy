#!/bin/sh -e
# - shell environment file for run-parts scripts in this directory
# (C) 2023-2025 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
#set -x

# install a lot of packages that might be of interest
PKGS=" \
  alpine-sdk
  abuild-rootbld
"

# install packages for tarballs
  apk add --no-cache $PKGS

# add aports
git clone --branch 3.23-stable --depth=1 https://gitlab.alpinelinux.org/alpine/aports.git /src/aports
