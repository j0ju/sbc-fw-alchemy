#!/bin/sh -e
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
#set -x
umask 022

# preseed git repo in /etc for etckeeper
cd /target/etc
rm -rf .git
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

tee > /dev/null .gitignore <<-EOF
	*-
	*~
	*.O
	resolv.conf
EOF

git add -f .gitignore
git commit -m "initial commit" -q

cd /
mkdir -p /target/tmp/cache/apk /target/tmp/cache/etckeeper
chroot /target apk add --no-cache etckeeper etckeeper-bash-completion

# FIXME: why? the commit is successful
rm -f /target/etc/.git/HEAD.lock /target/etc/.git/refs/heads/main.lock
