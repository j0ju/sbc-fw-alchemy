# this sets defaults for bmcd access via tpi
# enable and keep in sync with /etc/bmcd/config.yaml
# if changed

unset TPI_HOST
unset TPI_PORT

if [ -f /etc/conf.d/tpi ]; then
  . /etc/conf.d/tpi
fi

[ -z "$TPI_HOST" ] || \
  export TPI_HOST
[ -z "$TPI_PORT" ] || \
  export TPI_PORT
