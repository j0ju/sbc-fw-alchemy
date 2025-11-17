#!/bin/sh
# (C) 2023-2025 Joerg Jungermann, GPLv2 see LICENSE
set -e

IN="$1"
OUT="$2"

IMG="$(unzip -l "$IN" | grep -o -E "[^[:space:]]+[.]img")"

if ! unzip -p "$IN" "$IMG" > "$OUT"; then
  if ! unzip -p "$IN" "*.img" > "$OUT"; then
    # FIXME: this only works if there is an ".img" and only one in the .zip
    echo "E: issue extracting the image '$IMG' from '$IN'." >&2
    rm -f "$OUT"
    exit 1
  fi
fi

if [ ! -s "$OUT" ]; then
  echo "E: issue extracting the image '$IMG' from '$IN'." >&2
  rm -f "$OUT"
  exit 1
fi

[ -z "$OWNER" ] || \
  chown "$OWNER${GROUP:+:$GROUP}" "$OUT"
