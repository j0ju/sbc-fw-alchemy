# - /etc/profile.d/EDITOR.sh -
case "$(tty 2>/dev/null):$(which vim 2>/dev/null)" in
  /dev/ttyS*:* | /dev/ttyGS*:* | *: )
    export EDITOR="/bin/busybox vi"
    export VISUAL="/bin/busybox vi"
    alias vi="/bin/busybox vi"
    ;;
  *:/* )
    export EDITOR="$(which vim)"
    export VISUAL="$(which vim)"
    alias vi="$(which vim)"
    ;;
esac
