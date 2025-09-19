#!/bin/sh -eu
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE
PS4='> ${0##*/}: '
set -eu

. "$SRC/lib.sh"; init
#set -x

chroot /target \
  apt-get install -y \
    mc tmux screen vim-nox tcpdump mtr-tiny strace \
    lsof console-setup cifs-utils nfs-common pv ntfs-3g \
    ifupdown-ng ifupdown-ng-compat bird2 fastd \
  #
#
