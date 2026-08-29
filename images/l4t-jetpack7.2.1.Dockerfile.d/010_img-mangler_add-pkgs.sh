#!/bin/sh
# (C) 2025-26 Joerg Jungermann, GPLv2 see LICENSE
set -eu
PS4='> ${0##*/}: '
umask 022

set -x # DEBUG

apt-get update

apt-get install -y \
  whiptail
# EO apt-get
