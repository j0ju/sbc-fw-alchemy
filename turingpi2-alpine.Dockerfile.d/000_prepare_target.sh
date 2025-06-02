#!/bin/sh -e
# - shell environment file for run-parts scripts in this directory
# (C) 2024 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
#set -x
#
umask 022

# prepare /dev and resolv.conf
cp -a /dev/* /target/dev

rm -f /target/etc/resolv.conf
cp /etc/resolv.conf /target/etc/resolv.conf

# preseed git repo in /etc for etckeeper
( cd /target/etc
  git init .
  git config init.defaultBranch main
  git config user.name root
  git config user.email root@
  echo "resolv.conf"    >  .gitignore
  echo "*-"             >>  .gitignore
  echo "*~"             >>  .gitignore
  echo "*.O"            >>  .gitignore
  git add -f .gitignore
  git commit -m "initial commit" -q
)
