#!/bin/sh -eu
# (C) 2023-2025 Joerg Jungermann, GPLv2 see LICENSE

. "$SRC/lib.sh"; init
#set -x

chroot /target apt-get update
chroot /target \
  apt-get install -y \
    build-essential git \
    libasound2-dev g++ gcc make cmake groff gzip doxygen tar graphviz \
    libsigc++-2.0-dev \
    libspeex-dev libspeexdsp-dev libopus-dev libogg-dev \
    libpopt-dev \
    libasound2-dev libgcrypt20-dev libgsm1-dev \
    librtlsdr-dev libjsoncpp-dev \
    tcl-dev \
    libcurl4-openssl-dev \
    gpiod libgpiod-dev sigc++ \
  # EO apt-get install
# EO chroot
