#!/bin/sh -eu

#- files in $0.d will be pupolualated to rootfs in /target
FSDIR="$0.d"
if [ -d "$FSDIR" ]; then
  . "/src/img-mangler.Dockerfile.d/100_add_files.sh"
else
  . "$SRC/lib.sh"; init
fi

chroot /target locale-gen

chroot /target apt-get install -y \
  ifupdown2 frr \
  htop screen tmux vim-nox mc \
  tcpdump strace lsof \
  pciutils \
  zstd xz-utils \
  mtr-tiny \
  rsync \
  bind9-dnsutils \
  lldpd ntp sntp \
  #
