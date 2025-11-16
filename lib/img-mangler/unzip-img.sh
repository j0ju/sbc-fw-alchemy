#!/bin/sh
# (C) 2023-2025 Joerg Jungermann, GPLv2 see LICENSE
set -e
set -x

IN="$1"
OUT="$2"

IMG="$(unzip -l "$IN" | grep -o -E "[^[:space:]]+[.]img")"

if ! unzip -p "$IN" "$IMG" > "$OUT"; then
  if ! unzip -p "$IN" "*.img" > "$OUT"; then
    echo "E: issue extracting the image '$IMG' from '$IN'."
    rm -f "$OUT"
    exit 1
  fi
fi

[ -z "$OWNER" ] || \
  chown "$OWNER${GROUP:+:$GROUP}" "$OUT"
