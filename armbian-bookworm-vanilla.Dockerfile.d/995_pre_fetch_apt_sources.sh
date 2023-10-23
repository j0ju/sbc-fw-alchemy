#!/bin/bash -e
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '

chroot /target apt-get update
