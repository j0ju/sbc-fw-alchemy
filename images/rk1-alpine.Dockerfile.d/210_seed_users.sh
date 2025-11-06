#!/bin/sh
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE
set -eu

# settings
DEFAULT_USER=turing
DEFAULT_PW=rk1

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

chroot /target sh -eu <<EOchroot
  mkdir -p /home/$DEFAULT_USER/.ssh
  cp -a /root/.[!.]* /home/$DEFAULT_USER
  chown $DEFAULT_USER: /home/$DEFAULT_USER/.ssh
EOchroot

chroot /target etckeeper commit "${0##*/} finish"
# FIXME: why? the commit is successful
rm -f /target/etc/.git/HEAD.lock
