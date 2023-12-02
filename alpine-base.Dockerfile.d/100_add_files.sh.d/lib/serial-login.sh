#!/bin/sh

# unexport all other variables
for env in $(tr "\0" "\n" < /proc/$$/environ | sed 's/=.*$//') ""; do
  [ -z "$env" ] && \
    continue
  case "$env" in
    TERM | PATH ) continue ;;
  esac
  export "$env"=
  unset $env
done

# default umask and PATH
umask 0022
export PATH=/sbin:/bin:/usr/sbin:/usr/bin

# export HOME
UID="$(awk '/^Uid:/ { print $2}' /proc/$$/status)"
export HOME="$(awk -F: '/^[-a-zA-Z0-9]+:[^:]*:'"$UID"':/ {print $6}' /etc/passwd)"
cd "$HOME"

exec /bin/sh -
