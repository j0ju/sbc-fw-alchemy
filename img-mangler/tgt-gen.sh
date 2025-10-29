#!/bin/sh
set -eu

SUFFIX=

DIRS=
while [ $# != 0 ]; do
  for alt in "" .Dockerfile.d; do
    dir="$1$alt"
    if [ -f "$dir/Dockerfile.seed" ]; then
      DIRS="$DIRS $dir"
      shift
      break
    fi
    dir=
  done
  if [ -z "$dir" ]; then
    break
  fi
done

[ $# != 0 ] || \
  set -- ""
for SUFFIX; do
  for d in $DIRS; do
    ls -1d "$d"
  done | \
    sed -e 's|^|output/|' -e 's/.Dockerfile.d/.'"$SUFFIX"'/'
done
