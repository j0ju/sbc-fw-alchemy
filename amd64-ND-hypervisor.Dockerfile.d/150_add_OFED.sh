#!/bin/sh -eu

#- files in $0.d will be pupolualated to rootfs in /target
FSDIR="$0.d"
if [ -d "$FSDIR" ]; then
  . "/src/img-mangler.Dockerfile.d/100_add_files.sh"
else
  . "$SRC/lib.sh"; init
fi

set -x
chroot /target apt-get update
chroot /target apt-get install -yd \
  mlnx-ofed-kernel-utils mlnx-tools \
  mlnx-nvme-dkms mlnx-ofed-kernel-dkms \
  #
