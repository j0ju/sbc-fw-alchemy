#!/bin/sh
set -eu

PS4='> ${0##*/}: '
#set -x

# re-init some directories in rootfs
( cd /target/
  rmdir var/* 2> /dev/null || :
  rm -rf \
    run tmp srv home media \
    var/log var/spool/mail var/tmp \
    var/cache/apk var/cache/etckeeper var/cache/misc \
    var/lib/dbus var/lib/misc var/lib/rsyslog \
  # EO rm -rf

  # recreate some toplevel directories
  mkdir -p tmp overlay run
  chmod 1777 tmp

  # var/tmp
  ln -s ../tmp var/tmp
  ln -s ../tmp/log var/log
  ln -s ../../tmp/cache/apk var/cache/apk
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
  done

# pre-seed initial seed credentials
echo 'root:turingpi2!' | chpasswd

# change home of root to /tmp
sed -i -re 's|:/root:|:/tmp:|' /etc/passwd

# sort /etc/passwd | /etc/group
for f in passwd group; do
  sort -t: -k3 -n < /target/etc/$f > /target/etc/$f.new
  cat /target/etc/$f.new > /target/etc/$f
  rm -f /target/etc/$f.new
done

chroot /target etckeeper commit -m "${0##*/} finish"
