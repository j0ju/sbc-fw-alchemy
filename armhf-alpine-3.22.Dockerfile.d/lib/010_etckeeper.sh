#!/bin/sh -e
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
#set -x

umask 022

# preseed git repo in /etc for etckeeper
( cd /target/etc
  git init .

  git config init.defaultBranch main
  git config user.name root
  git config user.email root@

  git config alias.co checkout
  git config alias.br branch
  git config alias.ci commit
  git config alias.st status
  git config alias.stat status
  git config alias.l log --oneline

  : >  .gitignore
  echo "*-"             >>  .gitignore
  echo "*~"             >>  .gitignore
  echo "*.O"            >>  .gitignore
  echo "resolv.conf"    >>  .gitignore

  git add -f .gitignore
  git commit -m "initial commit" -q
)

chroot /target apk add --no-cache etckeeper
