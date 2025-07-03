#!/bin/sh
set -eu

PS4="> ${0##*/}[$$] > "
set -x
# this prevents bmcd from binding to /dev/ttyS[1234]
# this allow ungarbled access with minicom, screen, ...
MOCK_SERIAL=yes
STDOUT_TO_SYSLOG=yes

BMCD_CMDLINE=
while [ $# != 0 ]; do
  case "$1" in
    --no-serial | -S ) MOCK_SERIAL=yes ;;
    --serial    | -s ) MOCK_SERIAL=no ;;
    --syslog    | -L ) STDOUT_TO_SYSLOG=yes ;;
    --no-syslog | -l ) STDOUT_TO_SYSLOG=no ;;
    * )                BMCD_CMDLINE="$BMCD_CMDLINE $1"
  esac
  shift
done

# "tinker" environment to run bmcd
exec unshare -m -- sh -eu << EOF
  PS4="> ${0##*/}[\$$] > mountns > "
  set -x

  if [ "$MOCK_SERIAL" = yes ]; then
  # prepare /dev
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
  if [ "$STDOUT_TO_SYSLOG" = yes ]; then
    rm -f /run/bmcd.pipe
    mknod /run/bmcd.pipe p
    if [ "$MOCK_SERIAL" = yes ]; then
      mount -o bind -r /rom/dev/log /dev/log
    fi
    /usr/bin/logger -s -t "bmcd[$$]" < /run/bmcd.pipe &
    exec > /run/bmcd.pipe
    rm -f /run/bmcd.pipe
  fi

  # prepare /lib
  mount -o bind,ro,rprivate /srv/bmcd/bin/bmcd "$0"
  mount -o bind,ro,rprivate /srv/bmcd/lib /lib

  exec "$0" $BMCD_CMDLINE 2>&1
EOF
