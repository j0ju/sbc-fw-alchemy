#!/bin/sh
# (C) 2023-2026 Joerg Jungermann, GPLv2 see LICENSE

set -eu

. "$SRC/lib.sh"; # do not call init, here yet

chroot "$DST" apt-get update
chroot "$DST" apt-get install --no-install-recommends -y git tig

find "$DST" -name .git -exec rm -rf {} \+

( cd  "$DST/etc"
  git init .
  git config user.email "root@"
  git config user.name "root"
  : > .gitignore
  git add .gitignore
  git commit -m "initial commit"

  git config alias.co checkout
  git config alias.br branch
  git config alias.ci commit
  git config alias.st status
  git config alias.stat status
  git config alias.l log --oneline
)

tee > /dev/null "$DST/etc/.gitignore" <<EOF
*-
*~
*.O
*.sw[a-z]
*.lock
EOF

# add ssmtp to prevent exim installed
chroot "$DST" apt-get install -y --no-install-recommends etckeeper

# vim: noet sw=0 ts=2

