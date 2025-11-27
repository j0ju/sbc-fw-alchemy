#!/bin/sh -eu
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE
set -eu
PS4="> ${0##*/}: "
#set -x

# common parameters for SVXLink build and install
TAG=25.05.1
PREFIX="/opt/svxlink-$TAG"
KEEP_SOURCE=no # yes
NCPU=$(cat /proc/cpuinfo | grep -c ^processor) || NCPU=2
