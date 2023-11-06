#!/bin/sh -eu
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
#set -x

# pre-seed git config
( cd /target/etc
    git init .
    : > .gitignore
    echo "*-" >>  .gitignore
    git add -f .gitignore
    git commit -m "init" -q
)

#chroot /target /sbin/apk update
chroot /target /sbin/apk add --no-cache \
  openrc \
  minicom xxd vim mc procps psmisc coreutils bash avrdude screen tmux wavemon htop \
  bash-completion alpine-repo-tools-bash-completion openrc-bash-completion util-linux-bash-completion util-linux procs-bash-completion \
  git \
  lua 7zip findutils file strace bind-tools \
  sfdisk sgdisk btrfs-progs btrfs-compsize e2fsprogs f2fs-tools dosfstools lvm2 mdadm cryptsetup wipefs \
  mtr tcptraceroute traceroute fping arping iproute2 iproute2-bash-completion iproute2 ifupdown dhclient tcpdump sntpc \
  zip unzip 7zip unarj xz zstd bzip2 \
  iproute2-bash-completion git-bash-completion util-linux-bash-completion procs-bash-completion util-linux-bash-completion mtr-bash-completion \
  openssh \
  curl wget \
  rsync \
  u-boot-tools \
  file \
  usbutils hwids-usb \
  pv \
  ppp \
  wireguard-tools wireguard-tools-bash-completion \
  runit \
# EO chroot apk add
