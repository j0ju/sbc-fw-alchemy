#!/bin/sh -eu
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

#set -x
. "$SRC/lib.sh"; # do not call init, here yet

cp /lib/cleanup-rootfs.sh /target/lib

mkdir -p /target/etc/vim /target/etc/mc
cp /etc/vim/vimrc.local /target/etc/vim/

cp /etc/mc/mc.ini /target/etc/mc

cp /etc/gitconfig /target/etc
cp /etc/gitconfig /target/root/.gitconfig
cp /etc/gitconfig /target/etc/skel/.gitconfig

echo "# sources.list - disabled see sources.list.d" > /target/etc/apt/sources.list

chroot /target etckeeper commit -m "pre-seed config for git, vim, mc, apt"
