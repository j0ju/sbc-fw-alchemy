#!/bin/sh
set -eu

SUFFIX=

DIRS=
while [ $# != 0 ]; do
  for suffix in "" .Dockerfile.d; do
    for prefix in "" images/; do
      dir="$prefix$1$suffix"
      if ls > /dev/null 2>&1 $dir/Dockerfile.seed; then
        DIRS="$DIRS $dir"
        shift
        break
      fi
      dir=
    done
    if [ -n "$dir" ]; then
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
    ls -1d $d | \
      sed \
        -e "/[.]Workspace.d$/ d" \
        -e "s|^|${SUFFIX:+output/}|" \
        -e "s|.Dockerfile.d|${SUFFIX:+.$SUFFIX}|" \
      #
  done | sed 's|images/||'
done
