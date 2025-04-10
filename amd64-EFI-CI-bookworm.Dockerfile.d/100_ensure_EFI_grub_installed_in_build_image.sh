#!/bin/sh -eu
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
set -eu
#set -x

# this ensures that an EFI grub and binaries are installed so we can build bootable images for AMD64
dpkg --add-architecture amd64
apt-get update

# this implies building onyl works on amd64/arm64/i386
apt-get install -y grub-efi-amd64-bin grub-efi

