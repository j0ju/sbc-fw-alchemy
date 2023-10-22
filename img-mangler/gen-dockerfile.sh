#!/bin/sh
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE
set -e -u

DOCKERFILE="$1"
SEEDFILE="$2"
SEEDDIR="${2%/*}"

exec >> "$1"

cat "$2"
echo
echo "#---- auto generated section by $0"
echo "COPY ${SEEDDIR} /src/${SEEDDIR}/"
echo "ENV SRC=/src/$SEEDDIR"

for i in "$SEEDDIR"/[0-9][0-9][0-9]_*; do
  [ -f "$i" ] || \
    continue

  case "$i" in
    *.sh )
      echo ""
      echo "#- $i"
      echo "RUN exec /bin/sh -eu /src/${i#/}"
      ;;
    *.Dockerfile )
      echo ""
      echo "#- $i"
      cat "$i"
      ;;
  esac

done
