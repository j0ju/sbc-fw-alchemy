if which ifstat 2> /dev/null 1>&2; then
  _IFSTAT_BIN="${_IFSTAT_BIN:-$(which ifstat)}"
  ifstat() (
     PS4="> ifstat:"
     #set -x
     local ifstat_args=
     local arg itf
     while [ ! $# = 0 ]; do
       case "$1" in
         -i )
           shift
           for itf in $( < /proc/net/dev sed -n -r -e 's/:.*$// p'); do
             case "$itf" in
               $1 ) ifstat_args="$ifstat_args -i '$itf'" ;;
             esac
           done
           ;;
         * )
           ifstat_args="$ifstat_args '$1'"
       esac
       shift
     done
     eval "exec $_IFSTAT_BIN $ifstat_args"
  )
fi
