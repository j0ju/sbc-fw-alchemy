#! /bin/sh
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE
set -e

PKG=$1
OUTPUT_DIR=$2

mkdir -p "$OUTPUT_DIR"
BINPKG="$OUTPUT_DIR/$PKG.pkg.tar.gz"
echo "I: build $BINPKG"

FILES="$( \
  apk info --no-cache --no-network -q -L "$PKG" | \
    sed -r \
      -e '/^$/ d' \
      -e 's|^[/]*||' \
      -e '/[/]share[/](applications|icons)[/]/ d' \
    # EO sed
)"

LIBS="$(
  echo "$FILES" | grep -vE "(^usr/share/|/terminfo/)" | while read EXE; do
    ldd "/${EXE#/}" 2> /dev/null
  done | \
    grep -oE "/[-+_a-zA-Z0-9./]+" | \
    sort -u | \
    while read lib; do
      echo ${lib#/}
      while [ -L "$lib" ]; do
        lib="$(cd "${lib%/*}"; realpath "$(readlink "$lib")")"
        echo ${lib#/}
      done
    done | \
    sort -u
)"

#echo >&2 $PKG: $FILES
#echo >&2 $PKG: $LIBS

if [ -n "$FILES$LIBS" ]; then
  # do it this way so we keep the one file input criteria per line intact,
  # as we have unix line ending in variable captured
  ( echo "$FILES"
    echo "$LIB"
  ) | \
    grep -vE "^$" | \
    tr '\n' '\0' | \
    xargs -0 \
      tar czf $BINPKG -C /
fi

if [ ! -s "$BINPKG" ]; then :
  echo "W: $BINPKG is empty, removing" >&2
  rm -f "$BINPKG"
fi

