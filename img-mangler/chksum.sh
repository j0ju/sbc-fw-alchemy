#!/bin/sh
# (C) 2023-2025 Joerg Jungermann, GPLv2 see LICENSE

# This is a wrapper around shaXsum, md5sum, etc, as the syntax is different betwenn Linux, BSD and OSX
# It wraps to the ...sum command in a Docker container

set -e -u

CHKSUM="$2"
FILE="$1"

TYPE="${CHKSUM%%:*}"
CHKSUM="${CHKSUM##*:}"

case "$TYPE" in
  md5 | sha1 | sha256 ) ;; # OK
  "" )
    echo "W: no checksum for $FILE, ignoring" >&2
    exit 0
    ;;
  * )
    echo "E: unknown checksum $CHKSUM for $FILE" >&2
    exit 1
    ;;
esac

CHKSUMFILE=".deps/${FILE##*/}.$TYPE"sum
echo "$CHKSUM $FILE" > "$CHKSUMFILE"
[ -z "${OWNER:-}" ] || \
  chown "$OWNER${GROUP:+:$GROUP}" "$CHKSUMFILE"

if ! ./bin/img-mangler "$TYPE"sum -c "$CHKSUMFILE"; then
  chksum="$(./bin/img-mangler "$TYPE"sum "$FILE" | cut -f1 -d" " )"
  echo "E: checksum for $FILE does not match."
  echo "E: Expected $CHKSUM $TYPE."
  echo "E: It was   $chksum"
fi >&2

# vim: ts=2 sw=2 et
