#!/bin/sh -eu
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE

# common parameters for SVXLink build and install

. "$SRC/lib.sh"; init
#set -x

TAG=24.02
PREFIX="/opt/svxlink-$TAG"
