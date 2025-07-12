case "$USER" in
  node[1234] ) exec minicom $USER ;;
esac

case "$(tty)" in
  /dev/ttyS0 ) log ;;  
esac
