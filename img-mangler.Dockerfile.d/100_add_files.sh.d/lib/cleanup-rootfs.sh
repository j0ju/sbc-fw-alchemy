#!/bin/sh
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE
set -e

setx() {
  #echo "+$*"
  "$@"
}
if which apt-get > /dev/null; then
  apt-get clean
fi

for d in /usr/share/man/*; do
  [ -d "$d" ] || continue
  l="${d##*/}"
  case "$l" in
    man[0-9] )
      which man > /dev/null 2>&1 && continue || :
      ;;
  esac
  setx rm -rf "$d"
done

find /etc -name *.dpkg-* -delete
find /etc -name *.ucf-* -delete

rm -f 2> /dev/null \
  /var/cache/apt/archives/* \
  /var/cache/apt/archives/partial/* \
  /var/lib/apt/lists/* \
  /var/lib/apt/lists/partial/* \
  /var/lib/dpkg/info/*.preinst \
  /var/lib/dpkg/info/*.postinst \
  /var/log/* /var/log/*/* \
  /*.core /core.* \
  || :
rm -rf 2> /dev/null \
  /usr/share/doc/* \
  /usr/share/info/* \
  /usr/share/man/?? /usr/share/man/??.* /usr/share/man/??_?? \
  || : #
