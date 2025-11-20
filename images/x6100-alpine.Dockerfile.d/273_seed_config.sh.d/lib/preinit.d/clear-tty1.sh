( exec 2> /dev/null; set +e
  exec < /dev/tty1 > /dev/tty1
  setterm --cursor off --term linux
  clear
) || :
