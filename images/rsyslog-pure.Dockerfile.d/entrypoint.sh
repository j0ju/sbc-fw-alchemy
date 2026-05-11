#!/bin/sh
set -e

if [ "$1" = "-" ]; then
  /bin/busybox --install -s /bin
  exec /bin/ash -
fi

if [ -n "$UNIFIED_RSYSLOG_REMOTE" ]; then

  # disable stdout in rsyslog config
  sed -i -r \
      -e '/proc[\/]self[\/]fd/ s/^/#/' \
  /etc/rsyslog.conf

  #   templating if UNIFIED_RSYSLOG_REMOTE is set
  #       enable tcpforwarding queued
  sed -i -r \
      -e '/"omfwd"/ s|^#||' \
      -e '/"omfwd"/ s|[$]UNIFIED_RSYSLOG_REMOTE|'"$UNIFIED_RSYSLOG_REMOTE"'|' \
    /etc/rsyslog.conf
fi

# Q: other options to add via environment

# small thumbscrews
rm -f /bin/sh # remove shell
export PATH=

exec /usr/sbin/rsyslogd -n
