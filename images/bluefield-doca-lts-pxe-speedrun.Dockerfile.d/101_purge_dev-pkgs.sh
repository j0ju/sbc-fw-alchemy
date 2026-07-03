#!/bin/sh -eu
# (C) 2023-2025 Joerg Jungermann, GPLv2 see LICENSE

. "$SRC/lib.sh"; init
#set -x

# purge development pkgs, we use for now only hbn and snap which don't need those
# they are mostly a leftovers from bfb-built process -> https://github.com/Mellanox/bfb-build.git
# - remove DOCA dev files first, then debian
chroot /target \
  apt remove --purge -y \
    mlnx-dpdk-dev doca-devel-container doca-devel-user doca-devel \
    doca-openvswitch-dev \
    "libdoca-sdk-*-dev" \
    dpl-shm-dev dpl-p4rt-proto-dev dpl-rt-controller-dev dpl-p4rt-controller-dev \
    cpp gcc g++ build-essential \
    systemd-boot ubuntu-pro-client ubuntu-release-upgrader-core update-manager-core \
    pastebinit lxd-installer lxd-agent-loader \
    *-doc \
    sosreport \
    open-vm-tools \
    linux-bluefield-headers-6.8.0-1016 linux-headers-6.8.0-1016-bluefield-64k \
  # EO dpkg
# EO chroot

# apt-get remove --purge ubuntu-pro-client ubuntu-release-upgrader-core update-manager-core systemd-boot systemd-boot-efi:arm64 ubuntu-fan systemd-boot xauth opensm pastebinit lxd-installer lxd-agent-loader gcc gcc-13
#chroot /target \
#  dpkg -P $(dpkg -l *lib*-dev | awk '$1!="un" && $2~"^[^A-Z]" && $0=$2') \
#  # EO dpkg
# EO chroot

chroot /target \
  apt-get autoremove --purge -y
