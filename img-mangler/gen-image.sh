#!/bin/sh
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE
set -eu
set -x

# prepare a image file
# * create sparse file (if FS supports)

# sane defaults
ROUND_UP=1024
MIN_FREE=512

ROUND_UP_boot=32
MIN_FREE_boot=32

#--- calculate image size
USAGE_KB="$(du -sk /target | { read kb _; echo $kb; })"
USAGE_KB_boot="$(du -sk /target/boot | { read kb _; echo $kb; })"

MIN_FREE_SPACE_KB="$(( MIN_FREE * 1024 ))"
MIN_FREE_SPACE_KB_boot="$(( MIN_FREE_boot * 1024 ))"
ROUND_UP_KB="$(( ROUND_UP * 1024 ))"
ROUND_UP_KB_boot="$(( ROUND_UP_boot * 1024 ))"

PART_SIZE_KB_boot=$(( USAGE_KB_boot * 3 + MIN_FREE_SPACE_KB_boot ))
PART_SIZE_KB_boot=$(( ( PART_SIZE_KB_boot / ROUND_UP_KB_boot + 1 ) * ROUND_UP_KB_boot ))

IMAGE_SIZE_KB=$(( USAGE_KB + MIN_FREE_SPACE_KB + PART_SIZE_KB_boot ))
IMAGE_SIZE_KB=$(( ( IMAGE_SIZE_KB / ROUND_UP_KB + 1 ) * ROUND_UP_KB ))

IMAGE="$1"

: > $IMAGE
#--- generate sparse image
dd if=/dev/zero bs=1024 count=0 seek=$IMAGE_SIZE_KB of=$IMAGE status=none
#--- partition it
sfdisk $IMAGE > /dev/null <<EOF
  label: dos
  1: type=83 start=2048 bootable size=${PART_SIZE_KB_boot}KiB
  2: type=83
EOF

# vim: ts=2 sw=2 foldmethod=marker foldmarker=#-{,#}-
