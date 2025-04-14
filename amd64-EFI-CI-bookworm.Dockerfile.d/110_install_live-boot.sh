#!/bin/sh -eu
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE
PS4='> ${0##*/}: '
set -eu

. "$SRC/lib.sh"; init
#set -x

# this install live-boot, so we can boot this rootfs also from ISOs mounted via BMC, STICK or CDROM ;)
# this just add support for boot=live in initrd, and does not add much footprint nor side effects
# --> so install it always
chroot /target apt-get install -y live-boot

# don't wait for network, the processe have to wait for network
chroot /target systemctl disable systemd-networkd-wait-online.service 
chroot /target systemctl mask systemd-networkd-wait-online.service 
