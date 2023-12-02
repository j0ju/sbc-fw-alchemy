#!/bin/sh -eu
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

. "$SRC/lib.sh"; init
#set -x

cat > /target/etc/.gitignore << EOF
# NFS/Samba/ZFS share file
dfs/sharetab
zfs/zpool.cache
cups/*.O

# backup files
group-
gshadow-
passwd-
shadow-
subgid-
subuid-
resolv.conf-
resolv.conf

*.orig
*-
*.O
EOF

# pre-seed git config
( cd /target/etc
    git init .
    git add -f .gitignore
    git commit -m "init: add .gitignore" -q
)

chroot /target /sbin/apk add --no-cache \
  etckeeper
