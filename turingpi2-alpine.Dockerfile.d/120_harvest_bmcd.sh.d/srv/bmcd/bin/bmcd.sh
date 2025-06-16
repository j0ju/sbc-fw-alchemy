#!/bin/sh
set -eu

#set -x
# this prevents bmcd from binding to /dev/ttyS[1234]
# this allow ungarbled access with minicom, screen, ...
MOCK_SERIAL=yes

BMCD_CMDLINE=
while [ $# != 0 ]; do
  case "$1" in
    --no-serial | -S ) MOCK_SERIAL=yes ;;
    --serial    | -s ) MOCK_SERIAL=no ;;
    * )                BMCD_CMDLINE="$BMCD_CMDLINE $1"
  esac
  shift
done

# "tinker" environment to run bmcd
exec unshare -m -- sh -eu << EOF
  #set -x

  if [ "$MOCK_SERIAL" = yes ]; then
  # prepare /dev
    mount -o move,rprivate /dev /rom/dev
    mount -o rprivate -t tmpfs bmcd-dev /dev
    cp -a /rom/dev/* /dev
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
