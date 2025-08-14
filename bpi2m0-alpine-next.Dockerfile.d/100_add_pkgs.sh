#!/bin/sh
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE
set -eu
umask 022

PS4='> ${0##*/}: '
#set -x

PKGS=

# extras
PKGS="$PKGS
  file
  rsync
  make
  dtc
  sntpc
  strace lsof
  squashfs-tools
  zram-init
"

PKGS="$PKGS
  tzdata
"

PKGS="$PKGS
  python3
    pyc python3-pyc pyc
    python3-pycache-pyc0
    py3-certifi py3-certifi-pyc py3-charset-normalizer py3-charset-normalizer-pyc py3-distlib
    py3-distlib-pyc py3-dotenv py3-dotenv-pyc py3-filelock py3-filelock-pyc py3-idna py3-idna-pyc
    py3-packaging py3-packaging-pyc py3-parsing py3-parsing-pyc py3-pip py3-pip-bash-completion
    py3-pip-pyc py3-platformdirs py3-platformdirs-pyc py3-requests
    py3-requests-pyc py3-setuptools py3-setuptools-pyc py3-urllib3 py3-urllib3-pyc py3-virtualenv
    py3-virtualenv-pyc py3-yaml py3-yaml-pyc
    py3-pyserial py3-pyserial-pyc
"

PKGS="$PKGS
  podman
    podman-bash-completion podman-openrc podman-tui
    podman-compose podman-compose-bash-completion podman-compose-pyc
  nftables iptables
    nftables-openrc iptables-openrc nftables-vim
  bird2
  ppp
  dnsmasq dnsmasq-openrc dnsmasq-utils
"

PKGS="$PKGS
  sox
  groff doxygen graphviz
  alsa-tools alsa-utils bluez-alsa
  gsm-tools
  linux-tools-gpio
  lame
"

PKGS="$PKGS
  gcc g++ binutils make
  cmake autoconf autoconf-archive automake
  diffutils

  linux-headers
    libmd-dev libsamplerate-dev i2c-tools-dev
    libsigc++-dev alsa-lib-dev alsa-tools-dev
    gsm-dev curl-dev tcl-dev
    speexdsp-dev speex-dev popt-dev
    opus-dev opusfile-dev libogg-dev
    jsoncpp-dev lame-dev ladspa-dev libgcrypt-dev librtlsdr-dev
    ladspa-dev
"
# libgpiod-dev - SVXlink needs version 1.6 with 25.05.1

# install packages for tarballs
  mkdir -p /target/tmp/cache/apk /target/tmp/cache/etckeeper /target/tmp/cache/vim
  chroot /target apk add $PKGS

