init() {
  # disable invoke-rc.d
  mv /target/usr/sbin/invoke-rc.d /target/usr/sbin/invoke-rc.d.dist
  ln -s /bin/true /target/usr/sbin/invoke-rc.d

  # ensure we have a working resolv.conf
  mv /target/etc/resolv.conf /target/etc/resolv.conf-
  cp /etc/resolv.conf /target/etc/resolv.conf
  
  trap deinit EXIT
}

deinit() {
  local rs=$?

  case $rs in
    0 ) ;; # only commit /etc if exitcode is 0, otherwise we bailout and stop anyways
    * ) exit $rs ;;
  esac
  
  local SHOPTS=
  case "$-" in
    *x* ) SHOPTS=-x
  esac
  local PFX="${SRC##*/}"
  PFX="${PFX%.Dockerfile.d/}"

  # restore resolv.conf and invoke-rc.d
  rm -f /target/usr/sbin/invoke-rc.d /target/etc/resolv.conf
  mv /target/usr/sbin/invoke-rc.d.dist /target/usr/sbin/invoke-rc.d
  mv /target/etc/resolv.conf-  /target/etc/resolv.conf

  cd /target/etc
  if git status -s | grep ^ > /dev/null; then
    if ! git status -s | awk '$2 != "resolv.conf"' | grep ^ > /dev/null; then
      local logmsg="$(git show --pretty=format:%s -s HEAD)"
      git commit resolv.conf -n --amend -m "$logmsg"
    else
chroot /target /bin/sh -eu $SHOPTS <<EOF
      PS4="$PS4:chroot: "
      if which etckeeper > /dev/null; then
        etckeeper commit -m "${PFX}: ${0##*/} finish"
      fi
EOF
    fi
  fi
}

SRC="${SRC%/}"
