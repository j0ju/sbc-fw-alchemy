#!/bin/sh -e
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
#set -x

chroot /target /sbin/apk update
chroot /target /sbin/apk add \
  openrc \
  minicom vim mc procps psmisc coreutils bash avrdude screen tmux \
  bash-completion alpine-repo-tools-bash-completion openrc-bash-completion util-linux-bash-completion util-linux procs-bash-completion \
  git \
  lua 7zip findutils file strace bind-tools \
  sfdisk sgdisk btrfs-progs btrfs-compsize e2fsprogs f2fs-tools dosfstools lvm2 mdadm cryptsetup \
  mtr tcptraceroute traceroute fping arping iproute2 iproute2-bash-completion iproute2 ifupdown dhclient tcpdump sntpc \
  zip unzip 7zip unarj xz zstd bzip2 \
  iproute2-bash-completion git-bash-completion util-linux-bash-completion \
  openssh \
# EO chroot apk add
