#!/sbin/openrc-run

name="${RC_SVCNAME}"
command="/usr/local/sbin/bmcd"

CERTFILE="/etc/ssl/certs/bmcd_cert.pem"
KEYFILE="/etc/ssl/certs/bmcd_key.pem"
CONFIG="/etc/bmcd/config.yaml"

command_args="--config $CONFIG"
command_background=true
pidfile="${RC_PREFIX}/run/bmcd.pid"

depend() {
  need net otg
  use logger
  after firewall
}

start_pre() {
  if [ ! -f "$CERTFILE" ] || [ ! -f "$KEYFILE" ]; then
    sh /etc/bmcd/generate_self_signedx509.sh
  fi
}

start() {
  exec < /dev/null > /dev/kmsg 2>&1
  "$command" $command_args &
  echo $! > "$pidfile"
}
