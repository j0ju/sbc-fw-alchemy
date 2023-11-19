init() {
  mv /target/usr/sbin/invoke-rc.d /target/usr/sbin/invoke-rc.d.dist
  ln -s /bin/true /target/usr/sbin/invoke-rc.d

  cp /target/etc/resolv.conf /target/etc/resolv.conf-
  cat /etc/resolv.conf > /target/etc/resolv.conf
  
  trap deinit EXIT
}

deinit() {
  local rs=$?
  case $rs in
    0 )
      rm -f /target/usr/sbin/invoke-rc.d /target/etc/resolv.conf
      mv /target/usr/sbin/invoke-rc.d.dist /target/usr/sbin/invoke-rc.d
      mv /target/etc/resolv.conf-  /target/etc/resolv.conf
      ;;
  esac
  exit $rs
}

SRC="${SRC%/}"
