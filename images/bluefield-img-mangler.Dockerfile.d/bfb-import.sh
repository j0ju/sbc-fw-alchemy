#!/bin/sh
# (C) 2023-2025 Joerg Jungermann, GPLv2 see LICENSE
set -eu

IN="$1"
IMGNAME="$2"

BASEIMG=sbc:bluefield-img-mangler

case "$1:$2" in
  *: | :* )
    echo "E: wrong arguments: $0 [BFB] [IMAGENAME]" >&2
    exit 1
    ;;
esac

#CONTAINER="$( docker run -v --rm -d "$BASEIMG" tail -f /dev/null )"
CONTAINER="$( ./bin/img-mangler --image "$BASEIMG" -d tail -f /dev/null )"
trap "docker rm -f $CONTAINER > /dev/null" EXIT HUP INT QUIT PIPE KILL TERM

echo "UNPACK ${IN}"
docker exec -w /target                     $CONTAINER mlx-mkbfb -x "/src/input/${IN##*/}"

if docker exec -w /target                  $CONTAINER mv dump-initramfs-v0 dump-initramfs-v0.cpio.gz; then
  docker exec -w /target                   $CONTAINER mkdir -p dump-initramfs-v0
  echo "UNPACK ${IN} dump-initramfs-v0.cpio.gz"
  docker exec -w /target/dump-initramfs-v0 $CONTAINER sh -euc "gzip -cd < ../dump-initramfs-v0.cpio.gz | cpio -i --quiet"
  docker exec -w /target                   $CONTAINER rm -f dump-initramfs-v0.cpio.gz
  docker exec -w /                         $CONTAINER mv /target /bfb
  docker exec -w /                         $CONTAINER mkdir -p /target
fi

docker commit -c "CMD /bin/bash" -c "ENV DST=/target" "$CONTAINER" "$IMGNAME" > /dev/null
