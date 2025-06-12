#!/bin/sh -eu
# (C) 2023-2025 Joerg Jungermann, GPLv2 see LICENSE

#set -x
. "$SRC/lib.sh"; init

UIDS="995 996 997 998 999"
GIDS="995 996 997 998 999"

next_free_uid() {
  local fresh_uid="${1:-200}"
  while :; do
    < /target/etc/passwd awk -F':' '$3 == "'"$fresh_uid"'"' | grep ^ > /dev/null || \
      break
    fresh_uid=$((fresh_uid+1))
  done
  echo "$fresh_uid"
}

next_free_gid() {
  local fresh_gid="${1:-200}"
  while :; do
    < /target/etc/group awk -F':' '$3 == "'"$fresh_gid"'"' | grep ^ > /dev/null || \
    break
    fresh_gid=$((fresh_gid+1))
  done
  echo "$fresh_gid"
}

is_uid_used() {
  local uid="${1:-0}"
  < /target/etc/passwd awk -F':' '$3 == "'"$uid"'"' | grep ^ > /dev/null || return $?
}

is_gid_used() {
  local gid="${1:-0}"
  < /target/etc/group awk -F':' '$3 == "'"$gid"'"' | grep ^ > /dev/null || return $?
}

#- reassign gids
for gid in $GIDS; do
  #- check if GID is occupied
  is_gid_used $gid || continue
  #- get free GID
  fresh_gid="$(next_free_gid)"
  #echo "gid: $gid -> $fresh_gid"
  #- change GID /etc/group
  awk -F: '/^/ { OFS=":"; if ( $3=='"$gid"' ) $3='"$fresh_gid"'; print $0 }' < /target/etc/group > /target/etc/group-
  cat /target/etc/group- > /target/etc/group
  #- change GID /etc/passwd
  awk -F: '/^/ { OFS=":"; if ( $4=='"$gid"' ) $4='"$fresh_gid"'; print $0 }' < /target/etc/passwd > /target/etc/passwd-
  cat /target/etc/passwd- > /target/etc/passwd
  #- change filesystem permission
  find /target -xdev -gid $gid -exec chgrp $fresh_gid {} +
done

#- reassing uids
for uid in $UIDS; do
  #- check if GID is qccupied
  is_uid_used $uid || continue
  #- get free GID
  fresh_uid="$(next_free_uid)"
  #echo "uid: $uid -> $fresh_uid"
  #- change UID /etc/passwd
  awk -F: '/^/ { OFS=":"; if ( $3=='"$uid"' ) $3='"$fresh_uid"'; print $0 }' < /target/etc/passwd > /target/etc/passwd-
  cat /target/etc/passwd- > /target/etc/passwd
  #- change filesystem permission
  find /target -xdev -uid $uid -exec chown $fresh_uid {} +
done

#- cleanup any workfiles
rm /target/etc/passwd-
rm /target/etc/group-

sed -i -e s/,,,// /etc/passwd
pwck -s
grpck -s
