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
  openrc \
    openrc-bash-completion \
  iproute2 iproute2-ss iproute2-tc \
    iproute2-bash-completion \
  ifupdown-ng ifupdown-ng-iproute2 ifupdown-ng-wireguard ifupdown-ng-wireguard-quick \
  e2fsprogs f2fs-tools btrfs-progs \
    btrfs-progs-bash-completion \
  mdevd \
    mdevd-openrc \
  mc vim minicom tmux screen minicom \
  bird \
    bird-openrc \
  avahi avahi-tools \
  openresolv \
  git tig \
    git-bash-completion \
  etckeeper \
    etckeeper-bash-completion \
  curl wget \
  jq \
  file \
  sfdisk \
  blkid \
  mtr tcpdump \
  sed \
  u-boot-tools \
  partx \
  rsyslog \
  htop procps psmisc usbutils hwids-usb \
  xxd xz zstd bzip2 pv \
  strace lsof \
  coreutils \
  linuxconsoletools \
  rsync \
  wipefs \
  bash-completion \
    alpine-repo-tools-bash-completion \
    procs-bash-completion util-linux-bash-completion mtr-bash-completion \
    wireguard-tools-bash-completion \
  sntpc \
  dtc \
  make \
  python3 \
    pyc python3-pyc pyc
    python3-pycache-pyc0
    py3-certifi py3-certifi-pyc py3-charset-normalizer py3-charset-normalizer-pyc py3-distlib
    py3-distlib-pyc py3-dotenv py3-dotenv-pyc py3-filelock py3-filelock-pyc py3-idna py3-idna-pyc
    py3-packaging py3-packaging-pyc py3-parsing py3-parsing-pyc py3-pip py3-pip-bash-completion
    py3-pip-pyc py3-platformdirs py3-platformdirs-pyc py3-requests
    py3-requests-pyc py3-setuptools py3-setuptools-pyc py3-urllib3 py3-urllib3-pyc py3-virtualenv
    py3-virtualenv-pyc py3-yaml py3-yaml-pyc
"
    # python3-dev \

# install packages for tarballs
  chroot /target apk add --no-cache $PKGS

# fixes
  rm -f /target/sbin/ifstat
