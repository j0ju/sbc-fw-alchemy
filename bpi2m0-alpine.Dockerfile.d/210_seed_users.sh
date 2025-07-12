#!/bin/sh
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE
set -eu

# settings
DEFAULT_USER=pi
DEFAULT_PW=banana

PS4='> ${0##*/}: '
#set -x

chroot /target useradd $DEFAULT_USER

# change shell to bash
sed -i -re '/^root/ s|/sh|/bash|' /target/etc/passwd
sed -i -re "/^$DEFAULT_USER/"' s|/sh|/bash|' /target/etc/passwd

# pre-seed initial seed credentials
# explicitly lock the root account
echo 'root:*' | chroot /target chpasswd -e
chroot /target /usr/bin/passwd -l root

# default login for $DEFAULT_USER user
echo "$DEFAULT_USER:$DEFAULT_PW" | chroot /target chpasswd
chroot /target addgroup $DEFAULT_USER wheel

# copy over config seed
DST="${DST:-/target}"
FSDIR="$0.d"
cd "$FSDIR"
find . ! -type d | \
  while read f; do
    f="${f#./}"
    mkdir -p "${DST}/${f%/*}"
    case "$f" in
      */.placeholder ) continue ;;
    esac

    rm -f "${DST}/$f"
    chmod 0755 "${DST}/${f%/*}"

    mv "$f" "${DST}/$f"
    if [ ! -L "${DST}/$f" ]; then
      if [ -x "${DST}/$f" ]; then
        chmod 0755 "${DST}/$f"
      else
        chmod 0644 "${DST}/$f"
      fi
    fi
    echo " * /$f"
  done

# sort /etc/passwd | /etc/group
for f in passwd group; do
  sort -t: -k3 -n < /target/etc/$f > /target/etc/$f.new
  cat /target/etc/$f.new > /target/etc/$f
  rm -f /target/etc/$f.new
done

# seed user for $DEFAULT_USER config from root
chroot /target sh -eu <<EOchroot
  PS4='> ${0##*/}:chroot: '
  #set -x

  mkdir -p ~$DEFAULT_USER/.ssh
  for glob in "/root/[!.]*" "/root/.[!.]*"; do
    ls 2> /dev/null 1>&2 \$glob || continue
    cp -a \$glob ~$DEFAULT_USER
  done
  chown -R $DEFAULT_USER:$DEFAULT_USER ~$DEFAULT_USER
EOchroot

chroot /target etckeeper commit -m "${0##*/} finish"
