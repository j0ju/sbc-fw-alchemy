#!/bin/sh -eu
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE

# * PREFIX is defined in 200_svxlink_config.sh
# * this links svxlink ressources from $PREFIX/share/svxlink to
#   /usr/share/svxlink. This allows most tutorials and snippets to be
#   re-used, but not polluting to much the distribution rootfs
# * it patches the systemd unit so it will not use a log file but the systemd journal
#   this eases logrotation on SBCs and logshipping (if used)

. ${0%/*}/000_svxlink_config.sh
set -x

umask 022

#- put resource directory to a common location
rm -rf /target/usr/share/svxlink
ln -s "$PREFIX"/share/svxlink /target/usr/share/svxlink

#- link man and required libs to /usr/local
for f in /target/"$PREFIX"/share/man/man[0-9]/* /target/"$PREFIX"/lib/lib*.so*; do
  src="${f}"
    src="${src#/target}"
    src="${src#/}"
    src="${src%/}"
  PREFIX="$PREFIX"
  dst="/usr/local/${src#${PREFIX%/}}"
  dstdir="${dst%/*}"

  rm -f /target/"$dst"
  mkdir -p /target/"$dstdir"
  ln -s "$src" "/target/$dst"
done

#- create events.d for event overrides/extends
mkdir -p /target/etc/svxlink/events.d
chroot /target ln -s /etc/svxlink/events.d /usr/share/svxlink/events.d/local

#- streamline permissions
chroot /target chown svxlink: -R /etc/svxlink
chmod 750 /target/etc/svxlink /target/etc/svxlink/events.d

[ "$KEEP_SOURCE" != no ] || 
  rm -rf /target/$PREFIX/src

# copy over config seed
DST="/target"
FSDIR="$0.d"
! cd "$FSDIR" ||
find . ! -type d | \
  while read f; do
    mkdir -p "${DST}/${f%/*}"
    f="${f#./}"
    case "${f##*/}" in
      .placeholder ) continue ;;
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
