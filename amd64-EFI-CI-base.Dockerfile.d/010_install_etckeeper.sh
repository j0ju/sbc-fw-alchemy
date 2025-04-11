#!/bin/sh -eu
# (C) 2023-2025 Joerg Jungermann, GPLv2 see LICENSE

#set -x
. "$SRC/lib.sh"; # do not call init, here yet

find /target/ -name .git -exec rm -rf {} \+

( cd /target/etc
  git init .
  git config user.email "root@"
  git config user.name "root"
  : > .gitignore
  git add .gitignore
  git commit -m "initial commit"
)

# add ssmtp to prevent exim installed
chroot /target apt-get install -y etckeeper ssmtp
