#!/bin/sh -eu
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
#set -x

chroot /target \
  apt-get install -y \
    vim-nox mc \
    screen tmux \
    minicom lrzsz \
    tig \
    mtr-tiny \
    tcpdump strace \
    zstd pixz pigz unzip zip \
    busybox \
    sysstat ifstat \
    wavemon htop \
  ;\
chroot /target /bin/sh -c "\
  cd /etc; \
  git commit --amend -m 'apt-get: install base tooling' ;\
" ;\
