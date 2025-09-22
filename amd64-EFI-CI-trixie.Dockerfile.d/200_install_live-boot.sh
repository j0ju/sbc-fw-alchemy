#!/bin/sh -eu
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE
PS4='> ${0##*/}: '
set -eu

. "$SRC/lib.sh"; init
#set -x

# this install live-boot, so we can boot this rootfs also from ISOs mounted via BMC, STICK or CDROM ;)
# this just add support for boot=live in initrd, and does not add much footprint nor side effects
# --> so install it always
chroot "$DST" apt-get install -y live-boot

# don't wait for network, the processe have to wait for network
chroot "$DST" apt-get install -y live-boot \
    efibootmgr \
    dosfstools xfsprogs f2fs-tools btrfs-progs efibootmgr \
# EO
# this also install some tools to work with filesystems and the efi loader

# don't wait for network, the individual processes have to wait for network
chroot "$DST" systemctl disable systemd-networkd-wait-online.service
chroot "$DST" systemctl mask systemd-networkd-wait-online.service
