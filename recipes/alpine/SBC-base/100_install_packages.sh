#!/bin/sh -e
# - shell environment file for run-parts scripts in this directory
# (C) 2024-2026 Joerg Jungermann, GPLv2 see LICENSE

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

# FIXME: in Alpine 3.22/3.23 klogd user seems to be missing, although referenced in init script
# TODO:  is this still needed?
if ! chroot /target grep ^klogd: /etc/group > /dev/null; then
  chroot /target addgroup -S klogd
fi
if ! chroot /target grep ^klogd: /etc/passwd > /dev/null; then
  chroot /target adduser -S -D -H -h /dev/null -G klogd -g klogd -s /sbin/nologin klogd
fi
if ! chroot /target grep ^klogd: /etc/passwd > /dev/null; then
  echo "E: klogd user is missing, this should not have happend, ABORT" >&2
  exit 1
fi
