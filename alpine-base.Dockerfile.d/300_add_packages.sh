#!/bin/sh -eu
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

. "$SRC/lib.sh"; init
#set -x

chroot /target /sbin/apk add --no-cache \
  bash \
    bash-completion \
  procps psmisc coreutils \
    procs-bash-completion \
  openrc \
    openrc-bash-completion alpine-repo-tools-bash-completion \
  util-linux \
    util-linux-bash-completion \
  ifupdown \
    dhclient \
    ppp \
    sntpc \
  iproute2 \
    iproute2-bash-completion \
  wireguard-tools \
    wireguard-tools-bash-completion \
  mtr \
    mtr-bash-completion \
  openssh \
  \
  u-boot-tools \
  sfdisk sgdisk btrfs-progs btrfs-compsize e2fsprogs f2fs-tools dosfstools lvm2 mdadm cryptsetup wipefs \
  \
  git \
    git-bash-completion \
  \
  tcpdump \
  wavemon \
  minicom xxd \
  vim \
  mc screen tmux \
  htop \
  lua 7zip findutils file strace bind-tools \
  tcptraceroute traceroute fping arping \
  zip unzip 7zip unarj xz zstd bzip2 \
  curl wget \
  rsync \
  file \
  usbutils hwids-usb \
  pv \
  runit \
  agetty \
# EO chroot apk add
