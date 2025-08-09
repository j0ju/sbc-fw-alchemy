#!/sbin/openrc-run

command="/opt/mmdvm/bin/MMDVMHost"
command_background="true"
description="MMDVM"
pidfile="/run/$RC_SVCNAME.pid"
configfile="/etc/$RC_SVCNAME.ini"
instance="${RC_SVCNAME#*.}"

depend() {
        need net
        after firewall
        use dns
}

start() {
  daemonize &
}

daemonize() {
  read _pid _ < /proc/self/stat
  PIPE=/run/.$RC_SVCNAME.pipe
  rm -f $PIPE
  mknod $PIPE p
  /usr/bin/logger -t "$RC_SVCNAME[$_pid]" < $PIPE &
  exec > $PIPE 2>&1
  rm -f $PIPE

  renice -n -1 "$_pid"
  echo "$_pid" > "$pidfile"
  exec "$command" "$configfile"
}
