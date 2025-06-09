#!/bin/sh

SERVICE="$1"
ACTION="$2"
RUNLEVEL="$3"

case "$ACTION" in
  rotate )
    exit 0
    ;;
  * )
    logger -t "${0##*/}[$$]" -s "rc.d operations disabled" >&2
    exit 101
    ;;
esac
