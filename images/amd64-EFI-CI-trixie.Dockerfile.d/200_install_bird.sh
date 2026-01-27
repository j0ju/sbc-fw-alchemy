#!/bin/sh -eu
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE
PS4='> ${0##*/}: '
set -eu

. "$SRC/lib.sh"; init
set -x

apt-get install -y \
  apt-transport-https ca-certificates wget \
#

wget -O /usr/share/keyrings/cznic-labs-pkg.gpg https://pkg.labs.nic.cz/gpg
echo "deb [signed-by=/usr/share/keyrings/cznic-labs-pkg.gpg] https://pkg.labs.nic.cz/bird3 trixie main" > /etc/apt/sources.list.d/cznic-labs-bird3.list
apt-get update

apt-get install -y \
  bird3 \
#
