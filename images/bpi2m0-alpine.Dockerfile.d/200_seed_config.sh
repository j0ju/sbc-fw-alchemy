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
  mkdir -p tmp overlay run sys proc var/lib/misc
  chmod 1777 tmp

  # var/tmp
  ln -sf ../tmp var/tmp
  ln -sf ../tmp/log var/log
  ln -sf ../../tmp/cache/apk var/cache/apk
  ln -sf ../../tmp/cache/vim var/cache/vim
  ln -sf ../../tmp/cache/etckeeper var/cache/etckeeper
  ln -sf ../../tmp/lib/dbus var/lib/dbus
  ln -sf ../../tmp/lib/rsyslog var/lib/rsyslog
  # keep this image during build functioning
) # EO ( cd /target/
( cd /target/var
  find . -type l -exec readlink  {} \; | \
    while read d; do
      mkdir -p "$d"
    done
) # EO ( cd /target/var

# ensure ./bin and ./sbin below /usr/local
mkdir -p /target/usr/local/sbin /target/usr/local/bin

# tune avahi anounced services
rm -f /target/etc/avahi/services/sftp-ssh.service

# store build time for swclock
touch /target/var/lib/misc/openrc-shutdowntime

# ensure ifupdown directories
mkdir -p /target/etc/network/interfaces.d

# disable busybox su, SUID bit issues
rm -f /target/bin/su

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
    #echo " * /$f"
  done

# enable basic services
chroot /target /bin/sh -e > /dev/null <<EOF
rc-update add hostname sysinit
rc-update add sysfs sysinit
rc-update add sysfsconf sysinit
rc-update add sysctl sysinit
rc-update add procfs sysinit
rc-update add modules sysinit
rc-update add mdev sysinit
rc-update add hwdrivers sysinit
rc-update add syslog sysinit
rc-update add klogd sysinit
rc-update add swclock sysinit
rc-update add mmc sysinit

rc-update add networking default
rc-update add sshd default
rc-update add avahi-daemon default
rc-update add chronyd default

rc-update add killprocs shutdown
rc-update add mount-ro shutdown

ln -s getty /etc/init.d/getty.ttyS0
ln -s getty /etc/init.d/getty.ttyGS0
rc-update add getty.ttyS0 sysinit
rc-update add getty.ttyGS0 default

/usr/local/sbin/update-rc
EOF

( cd /target/boot/overlay-user
  make
)

chroot /target etckeeper commit "${0##*/} finish"
rm -f /target/etc/.git/HEAD.lock
