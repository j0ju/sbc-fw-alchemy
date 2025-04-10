#!/bin/sh -eu
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
set -eu
#set -x

#- install live build to build image
apt-get install -y live-build

#- prepare /livebuild
. /target/etc/os-release # get Debian codename/suite
#mkdir -p /livebuild
#( cd /livebuild
#  lb config -d "$VERSION_CODENAME"
#)

#- intial bootstrap of rootfs of same version level as image in /target
# this needs a priviledged container
#( cd /livebuild
#  lb bootstrap
#)
