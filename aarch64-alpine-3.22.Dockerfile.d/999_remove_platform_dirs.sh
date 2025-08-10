#!/bin/sh -e
# - shell environment file for run-parts scripts in this directory
# (C) 2024-2025 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
#set -x

# remove any platform specific blobs
rm -rf /target/boot /target/lib/modules /target/lib/firmware
