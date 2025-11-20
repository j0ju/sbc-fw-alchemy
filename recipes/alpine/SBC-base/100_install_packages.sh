#!/bin/sh -e
# - shell environment file for run-parts scripts in this directory
# (C) 2024-2025 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
#set -x

PKGS=" \
  bash \
  mc vim tmux minicom \
  avahi avahi-tools \
  openresolv \
  kmod \
  curl wget \
  mtr tcpdump \
    mtr-bash-completion \
  ppp-chat \
  sed \
  u-boot-tools \
  rsyslog \
  htop procps psmisc usbutils hwids-usb \
  xxd xz zstd pv tar \
  coreutils \
  bash-completion \
    alpine-repo-tools-bash-completion \
    procs-bash-completion \
  openssl \
  busybox-openrc busybox-mdev-openrc \
"

mkdir -p /target/var/lib/apk

# we install these pkgs in advance so -openrc and -bash-completion are installed
# as recomends automatically for user convinience
  chroot /target apk add bash-completion openrc

# install packages for tarballs
  chroot /target apk add $PKGS
