#!/bin/sh -eu
# (C) 2023-2025 Joerg Jungermann, GPLv2 see LICENSE

. "$SRC/lib.sh"; # do not call init, here yet
set -x

chroot "$DST" apt-get install -y git ssmtp

find "$DST" -name .git -exec rm -rf {} \+

( cd  "$DST/etc"
  git init .
  git config user.email "root@"
  git config user.name "root"
  : > .gitignore
  git add .gitignore
  git commit -m "initial commit"
)

# add ssmtp to prevent exim installed
chroot "$DST" apt-get install -y etckeeper ssmtp
