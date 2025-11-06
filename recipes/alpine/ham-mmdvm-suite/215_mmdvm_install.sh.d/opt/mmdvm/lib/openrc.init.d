#!/sbin/openrc-run
description="$RC_SVCNAME"
supervisor="supervise-daemon"
pidfile="/run/$RC_SVCNAME.pid"

command=/bin/sh
command_args="-eu /etc/init.d/${RC_SVCNAME} daemonize"
command_background=true

niceness=-1

prog="/opt/mmdvm/bin/$RC_SVCNAME"
prog_args="/etc/$RC_SVCNAME.ini"

depend() {
	need net
	after firewall
	use dns
}

daemonize() {
  . "/etc/init.d/${RC_SVCNAME}"
  ! [ -r "/etc/conf.d/${RC_SVCNAME}" ] || \
    . "/etc/conf.d/${RC_SVCNAME}"

  read _pid _ < /proc/self/stat
  PIPE="/run/.$RC_SVCNAME.pipe.$( tr -cd '_+:a-z0-9A-Z' < /dev/urandom | head -c 32 ).$_pid"

  rm -f "$PIPE"
  mknod "$PIPE" p
  /usr/bin/logger -t "${RC_SVCNAME}[$_pid]" < $PIPE &
  exec > "$PIPE" 2>&1
  rm -f "$PIPE"

  exec nice -n $niceness "$prog" $prog_args
}

case "$RC_SVCNAME:$1" in
  ":daemonize" )
    RC_SVCNAME="${0##*/}"
    daemonize
    ;;
esac
