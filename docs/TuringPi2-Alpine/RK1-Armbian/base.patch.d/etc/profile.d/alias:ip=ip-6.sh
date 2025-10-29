ip() (
  local opt=
  local af= # -6
  case "$1:$2" in
    a*: ) af= ; opt="-br" ;;
    -4:* | -6:* ) af="$1"; shift ;;
  esac
  exec /sbin/ip $af $opt "$@"
)
