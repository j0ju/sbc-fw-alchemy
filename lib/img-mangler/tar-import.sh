#!/bin/sh
# (C) 2023-2025 Joerg Jungermann, GPLv2 see LICENSE
set -e

IN="$1"
IMGNAME="$2"

case "$1:$2" in
  *: | :* )
    echo "E: wrong arguments: $0 [ROOTFS TARBALL] [IMAGENAME]" >&2
    exit 1
    ;;
esac

CONTAINER="$(docker run --rm -d sbc:img-mangler tail -f /dev/null)"
trap "docker rm -f $CONTAINER > /dev/null" EXIT HUP INT QUIT PIPE KILL TERM

DECOMPRESSOR=cat

docker exec "$CONTAINER" mkdir -p /target
case "$IN" in
  *.zst | *.zstd ) DECOMPRESSOR="zstd -cd" ;;
  *.gz | *.tgz ) DECOMPRESSOR="gzip -cd" ;;
  *.xz | *.txz ) DECOMPRESSOR="xz -cd" ;;
esac

$DECOMPRESSOR < "$IN" | \
  docker exec -i "$CONTAINER" tar xf - --xattrs --selinux --acls --atime-preserve --numeric-owner -C /target > /dev/null

docker commit -c "CMD /bin/bash" -c "ENV DST=/target" "$CONTAINER" "$IMGNAME" > /dev/null
