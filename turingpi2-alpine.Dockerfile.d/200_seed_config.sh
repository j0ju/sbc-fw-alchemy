#!/bin/sh
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE
set -eu

PS4='> ${0##*/}: '
#set -x

# re-init some directories in rootfs
( cd /target/
  rmdir var/* 2> /dev/null || :
  rm -rf \
    run tmp home media \
    etc/machine-id \
    var/log var/spool/mail var/tmp \
    var/cache/apk var/cache/etckeeper var/cache/misc \
    var/lib/dbus var/lib/misc var/lib/rsyslog \
  # EO rm -rf

  # recreate some toplevel directories
  mkdir -p tmp overlay run sys proc
  chmod 1777 tmp

  # var/tmp
  ln -s ../tmp var/tmp
  ln -s ../tmp/log var/log
  ln -s ../../tmp/cache/apk var/cache/apk
  ln -s ../../tmp/cache/vim var/cache/vim
  ln -s ../../tmp/cache/etckeeper var/cache/etckeeper
  ln -s ../../tmp/lib/dbus var/lib/dbus
  ln -s ../../tmp/lib/rsyslog var/lib/rsyslog
  # keep this image during build functioning
) # EO ( cd /target/
( cd /target/var
  find . -type l -exec readlink  {} \; | \
    while read d; do
      mkdir -p "$d"
    done
) # EO ( cd /target/var

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

# pre-seed initial seed credentials
echo 'root:turing' | chroot /target chpasswd

# change home of root to /run - less writes to MMC/flash
sed -i -re 's|:/root:|:/run:|' /target/etc/passwd
# change shell to bash
sed -i -re '/^root/ s|/sh|/bash|' /target/etc/passwd

# sort /etc/passwd | /etc/group
for f in passwd group; do
  sort -t: -k3 -n < /target/etc/$f > /target/etc/$f.new
  cat /target/etc/$f.new > /target/etc/$f
  rm -f /target/etc/$f.new
done

# ensure *bin below /usr/local
mkdir -p /target/usr/local/sbin /target/usr/local/bin

# tune avahi anounced services
rm -f /target/etc/avahi/services/sftp-ssh.service

# enable basic services
chroot /target /bin/sh -e <<EOF
rc-update add hostname sysinit
rc-update add sysfs sysinit
rc-update add sysfsconf sysinit
rc-update add sysctl sysinit
rc-update add procfs sysinit
rc-update add hwclock sysinit
rc-update add modules sysinit
rc-update add otg sysinit
rc-update add mdev sysinit
rc-update add syslog sysinit
rc-update add klogd sysinit

rc-update add networking default
rc-update add sshd default
rc-update add avahi-daemon default
rc-update add chronyd default
rc-update add bmcd default
rc-update add dot default
rc-update add mmc default

rc-update add killprocs shutdown
rc-update add mount-ro shutdown

/usr/local/sbin/update-rc 1> /dev/null
EOF

chroot /target etckeeper commit -m "${0##*/} finish"
