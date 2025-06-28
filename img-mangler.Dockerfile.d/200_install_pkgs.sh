#!/bin/sh -e
# (C) 2023-2025 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
#set -x

apt-get update 
apt-get install -y --no-install-recommends \
  debootstrap \
  fdisk gdisk kpartx \
  dosfstools e2fsprogs btrfs-progs f2fs-tools \
  libubootenv-tool u-boot-tools \
  unzip unrar zstd file pixz xzip cpio pigz \
  python3-pip virtualenv direnv \
  qemu-user-static \
  mc vim-nox bash-completion \
  procps psmisc man-db \
  git \
  build-essential libncurses-dev \
  rsync bc cmake bzip2 \
  bspatch bsdiff hexer bbe \
  strace tcpdump \
  squashfs-tools squashfs-tools-ng \
  mtools xorriso mkisofs \
  live-build live-boot live-config \
  xxd \
  device-tree-compiler dt-utils \
# EO apt-get install

# this ensures that an EFI grub and binaries are installed so we can build bootable images for AMD64
# this implies building onyl works on amd64/arm64/i386
dpkg --add-architecture amd64
apt-get update
apt-get install -y grub-efi-amd64-bin grub-efi
