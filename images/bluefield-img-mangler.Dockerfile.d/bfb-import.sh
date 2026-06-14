#!/bin/sh
# (C) 2023-2026 Joerg Jungermann, GPLv2 see LICENSE
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

docker commit -c "CMD /bin/bash" -c "ENV DST=/target" "$CONTAINER" "$IMGNAME" > /dev/null
