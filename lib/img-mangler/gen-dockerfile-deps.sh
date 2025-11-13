#!/bin/sh
set -eu

DOCKERFILE="${1}"

IMAGE="${1}"
IMAGE="${IMAGE#input/}"
IMAGE="${IMAGE%.Dockerfile}"

if [ -n "${2:-}" ]; then
  atexit() {
    local rs=$?
    if [ "$rs" != 0 ]; then
      rm -f "$2"
    fi
    exit $?
  }
  trap 'atexit' EXIT
  exec > "$2"
  DEPFILE="$2"
fi

(
  awk '$1 == "FROM" { print $2 }' "$1" | \
    while read -r image; do
      image_pfx="${image%%:*}"
      if [ "$image_pfx" = "$NAME_PFX$NAME" ]; then
        echo "$DEPDIR/${image#$NAME:}.built"
      fi
    done

  awk '$1 ~ "^(ADD|COPY)$" && $2 !~ "[*?]" {print}' "$1" | while read -r line; do
    case "$line" in
      *--from* ) # generate dependencies to images generate by this toolchain
        # ignore this is handled via FROM
        ;;
      * ) # generate dependencies to files inside this toolchain
        set -- $line
        shift
        dirs=
        while [ $# -gt 1 ]; do
          dirs="$dirs $1"
          shift
        done
        for d in $dirs; do
          find "$d" -type f | grep -v "/[^/]*[.]sw[a-z]$" || :
        done
        ;;
    esac
  done
) | {
  buildeps=
  filedeps=
  while read d; do
    case "$d" in
      *.built ) buildeps="$buildeps $d" ;;
      * )       filedeps="$filedeps $d" ;;
    esac
  done
  echo "$DEPDIR/$IMAGE.built: $buildeps $filedeps"
  echo "$DOCKERFILE: $filedeps"
}

echo "$DEPFILE: $DOCKERFILE"
echo "$IMAGE: $DEPDIR/$IMAGE.built"
echo ".PHONY: $IMAGE"

