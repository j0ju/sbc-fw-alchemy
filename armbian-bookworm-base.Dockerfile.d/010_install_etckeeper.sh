#!/bin/sh -eu
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

#set -x
. "$SRC/lib.sh"; # do not call init, here yet

find /target/ -name .git -exec rm -rf {} \+

cp "$0.d/etc-dot-gitignore" /target/etc/.gitignore
( cd /target/etc
  git init .
  git config user.email "root@"
  git config user.name "root"
  git add .gitignore
  git commit -m ".gitignore"
)

chroot /target apt-get install -y etckeeper
