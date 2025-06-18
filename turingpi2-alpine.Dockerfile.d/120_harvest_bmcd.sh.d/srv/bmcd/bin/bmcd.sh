#!/bin/sh
set -eu

# this a quick and dirty hack to run the BMC compiled for buildroot (glibc) on alpine (musl).
# FIXME: build and run nativly with musl

#set -x
# this prevents bmcd from binding to /dev/ttyS[1234]
# this allow ungarbled access with minicom, screen, ...
MOCK_SERIAL=yes # set it the default as IMHO currently the serial feautre of the BMC is useless

BMCD_CMDLINE=
while [ $# != 0 ]; do
  case "$1" in
    --no-serial | -S ) MOCK_SERIAL=yes ;;
    --serial    | -s ) MOCK_SERIAL=no ;;
    * )                BMCD_CMDLINE="$BMCD_CMDLINE $1"
  esac
  shift
done

# "tinker" environment to run bmcd using a diffrent mount namespace to move mountpoints around
exec unshare -m -- sh -eu << EOF
  #set -x

  if [ "$MOCK_SERIAL" = yes ]; then
  # prepare /dev
  #  * move old /dev to /rom/dev
  #  * mount tmpfs to /rom/tmp
  #  * overlay upper=/rom/tmp and lower=/rom/dev to /dev
  #  this way we get mdev/hotplug updates in /dev, besides the tty modifcations below
  #  this allow tpi msd to work
    mount -o move,rprivate /dev /rom/dev
    mount -t tmpfs tmpfs /rom/tmp -o size=256k

    mkdir -p /rom/tmp/upper /rom/tmp/work
    mount -t overlay -o lowerdir=/rom/dev,upperdir=/rom/tmp/upper,workdir=/rom/tmp/work bmcd-dev-overlay /dev

    rm -f /dev/ttyS[1234]
    ln -s tty7 /dev/ttyS1
    ln -s tty7 /dev/ttyS2
    ln -s tty7 /dev/ttyS3
    ln -s tty7 /dev/ttyS4
  fi

  # prepare /lib
  mount -o bind,ro,rprivate /srv/bmcd/lib /lib

  exec /srv/bmcd/bin/bmcd $BMCD_CMDLINE
EOF
