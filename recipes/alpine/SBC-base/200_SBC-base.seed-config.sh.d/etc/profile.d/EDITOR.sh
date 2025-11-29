# - /etc/profile.d/EDITOR.sh -

case "$TERM:$(tty 2>/dev/null):$(which vim 2>/dev/null)" in
  screen:*:/* | \
  xterm*:*:/* | \
  linux:*:/*  )
    export EDITOR="$(which vim)"
    export VISUAL="$(which vim)"
    alias vi="$(which vim)"
    ;;
  vt100:*              | \
  *:/dev/tty[A-Z]*:*   | \
  *:                   )
    export EDITOR="/bin/busybox vi"
    export VISUAL="/bin/busybox vi"
    alias vi="/bin/busybox vi"
    ;;
esac
