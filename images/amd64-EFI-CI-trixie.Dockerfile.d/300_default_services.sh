#!/bin/sh -eu
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE
PS4='> ${0##*/}: '
set -eu

. "$SRC/lib.sh"; init
set -x

# don't wait for network, the individual processes have to wait for network
chroot "$DST" systemctl disable \
  rpcbind.service \
  nfs-blkmap.service \
  nfs-client.target \
  nss-lookup.target \
  rsync.service \
  bird.service \
  apparmor.service \
#

chroot "$DST" systemctl mask \
  fastd.service \
#

chroot "$DST" systemctl enable \
  systemd-networkd.service \
  ssh.service \
  networking.service \
#

chroot "$DST" rm -f \
  /etc/init.d/fastd \
  /etc/init.d/rsync \
#
