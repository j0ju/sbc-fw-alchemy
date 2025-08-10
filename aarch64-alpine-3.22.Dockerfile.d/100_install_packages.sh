#!/bin/sh -e
# - shell environment file for run-parts scripts in this directory
# (C) 2024-2025 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
#set -x

PKGS=" \
  bash \
  openssh-server \
  chrony \
    chrony-openrc \
  openrc openrc-init \
    openrc-bash-completion \
  iproute2 iproute2-ss iproute2-tc \
    iproute2-bash-completion \
  ifupdown-ng ifupdown-ng-iproute2 ifupdown-ng-wireguard ifupdown-ng-wireguard-quick \
  e2fsprogs f2fs-tools \
  wipefs \
  mount \
  util-linux util-linux-misc \
    util-linux-bash-completion \
  mc vim minicom tmux minicom \
  avahi avahi-tools \
  openresolv \
  kmod \
  git \
    git-bash-completion \
  etckeeper \
    etckeeper-bash-completion \
  curl wget \
  sfdisk \
  blkid \
  mtr tcpdump \
    mtr-bash-completion \
  ppp-chat \
  sed \
  u-boot-tools \
  partx \
  rsyslog \
  htop procps psmisc usbutils hwids-usb \
  xxd xz zstd pv tar \
  coreutils \
  bash-completion \
    alpine-repo-tools-bash-completion \
    procs-bash-completion \
    wireguard-tools-bash-completion \
  openssl \
  busybox-openrc busybox-mdev-openrc \
"

# extras
#PKGS="$PKGS \
#  busybox-static \
#  file \
#  rsync \
#  make \
#  sntpc \
#  strace lsof \
#"

# DISABLED:
#PKGS="$PKGS \
#  python3 \
#    pyc python3-pyc pyc
#    python3-pycache-pyc0
#    py3-certifi py3-certifi-pyc py3-charset-normalizer py3-charset-normalizer-pyc py3-distlib
#    py3-distlib-pyc py3-dotenv py3-dotenv-pyc py3-filelock py3-filelock-pyc py3-idna py3-idna-pyc
#    py3-packaging py3-packaging-pyc py3-parsing py3-parsing-pyc py3-pip py3-pip-bash-completion
#    py3-pip-pyc py3-platformdirs py3-platformdirs-pyc py3-requests
#    py3-requests-pyc py3-setuptools py3-setuptools-pyc py3-urllib3 py3-urllib3-pyc py3-virtualenv
#    py3-virtualenv-pyc py3-yaml py3-yaml-pyc
#"

#PKGS="$PKGS \
#  btrfs-progs \
#    btrfs-progs-bash-completion \
#  tig \
#  bird \
#    bird-openrc \
#  python3-dev \
#  ppp \
#  jq \
#  dtc \
#"

# we install these pkgs in advance so -openrc and -bash-completion are installed
# as recomends automatically for user convinience
  chroot /target apk add bash-completion openrc

# install packages for tarballs
  chroot /target apk add $PKGS

# fixes
  rm -f /target/sbin/ifstat
