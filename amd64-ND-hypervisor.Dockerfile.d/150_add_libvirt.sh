#!/bin/sh -eu

#- files in $0.d will be pupolualated to rootfs in /target
FSDIR="$0.d"
if [ -d "$FSDIR" ]; then
  . "/src/img-mangler.Dockerfile.d/100_add_files.sh"
else
  . "$SRC/lib.sh"; init
fi

chroot /target apt-get install -y -t bookworm \
  dnsmasq \
  bridge-utils \
  lz4 \
  gdisk \
  #

chroot /target apt-get install -y -t bookworm-backports \
  qemu-system qemu-system-x86 qemu-utils \
  libvirt-daemon-system libvirt-clients \
  libguestfs-tools \
  #
