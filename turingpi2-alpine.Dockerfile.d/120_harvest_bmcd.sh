#!/bin/sh
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE
set -eu
umask 022

PS4='> ${0##*/}: '
#set -x

PREFIX=/srv/bmcd
BINARIES="bmcd tpi"
# TODO: compile bmcd and tpi for alpine
#
# for now use `ldd` from glibc to extract all needed libs and put them to /opt/bmcd
# * for binaires
#   * bmcd
#   * tpi
# * copy over resources, too
#
# /vanilla contains the buildroot's rootfs

# copy glibc ldd script from debian to tpi buildroot
cp $(which ldd) /vanilla/bin
# patch runtime loader list
RTLDLIST="$(chroot /vanilla sh -c "ls /lib/ld-*.so.*")"
sed -i -r -e 's|^RTLDLIST=.*$|RTLDLIST="'"$RTLDLIST"'"|' /vanilla/bin/ldd

# copy data
mkdir -p /target/$PREFIX 
cp -a /vanilla/srv/bmcd /target/${PREFIX%/*}
cp -a /vanilla/etc/bmcd /target/etc
chmod a-x /target/etc/bmcd/*

# copy runtime
copy_runtime() {
  mkdir -p /target/$PREFIX/bin
  mkdir -p /target/$PREFIX/lib
  while read f; do
    case "$f" in
      */bin/* ) cp /vanilla/"$f" /target/$PREFIX/bin ;;
      */lib/* ) cp /vanilla/"$f" /target/$PREFIX/lib ;;
    esac
  done
}
for bin in bmcd tpi; do
  chroot /vanilla which $bin
  chroot /vanilla /bin/ldd "$(chroot /vanilla which $bin)"
done | grep -Eo "/[^ ]+" | sort -u | copy_runtime

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

# link wrappers to /usr/local/bin/sbin
chmod 0755 /target/srv/bmcd/bin/*
mkdir -p /target/usr/local/bin /target/usr/local/sbin
ln -s /srv/bmcd/bin/tpi.sh /target/usr/local/bin/tpi
ln -s /srv/bmcd/bin/bmcd.sh /target/usr/local/sbin/bmcd

mv /target/srv/bmcd/bin/bmc-otg.init.d /target/etc/init.d/otg
mv /target/srv/bmcd/bin/bmcd.init.d /target/etc/init.d/bmcd
