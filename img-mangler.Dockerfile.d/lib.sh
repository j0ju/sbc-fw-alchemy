#!/bin/sh
#- lib for mangling

set -e
PS4="> ${0##*/}: "
SRC="${SRC%/}"

init() {
  [ -d /target ] || return 0

  local PFX="${SRC##*/}"
  PFX="${PFX%.Dockerfile.d/}"

  etckeeper_commit "${PFX}: ${0##*/} start"

  # disable invoke-rc.d
  if [ ! "${__lib_sh_init:-no}" = yes ]; then
    if [ -f /target/usr/sbin/invoke-rc.d ]; then
      mv /target/usr/sbin/invoke-rc.d /target/usr/sbin/invoke-rc.d.dist
      ln -s /bin/true /target/usr/sbin/invoke-rc.d
    fi
    if [ -f /bin/systemd-detect-virt ]; then
      mv /target/bin/systemd-detect-virt /target//bin/systemd-detect-virt.dist
      ln -s /bin/true /target/bin/systemd-detect-virt
    fi

  # ensure we have a working resolv.conf
    mv /target/etc/resolv.conf /target/etc/resolv.conf-
    cp /etc/resolv.conf /target/etc/resolv.conf
    __lib_sh_init=yes
  fi
  
  trap deinit EXIT
}

deinit() {
  local rs=$?
  [ -d /target ] || return $rs

  case $rs in
    0 ) ;; # only commit /etc if exitcode is 0, otherwise we bailout and stop anyways
    * ) return $rs ;;
  esac
  
  if [ -f /target/usr/sbin/invoke-rc.d.dist ]; then
    rm -f /target/usr/sbin/invoke-rc.d
    mv /target/usr/sbin/invoke-rc.d.dist /target/usr/sbin/invoke-rc.d
  fi
  if [ -f /target/bin/systemd-detect-virt.dist ]; then
    rm -f /target/bin/systemd-detect-virt
    mv /target/bin/systemd-detect-virt.dist /target/bin/systemd-detect-virt
  fi
  rm -f /target/etc/resolv.conf
  mv /target/etc/resolv.conf-  /target/etc/resolv.conf

  local PFX="${SRC##*/}"
  PFX="${PFX%.Dockerfile.d/}"
  etckeeper_commit "${PFX}: ${0##*/} finish"

  return $rs
}

etckeeper_commit() (
  local SHOPTS="$(echo $- | tr -cd 'eux')"
  local git_commit_message="$1"

  cd /target/etc
  if git status -s 2>/dev/null | grep ^ > /dev/null; then
chroot /target /bin/sh -$SHOPTS <<EOF
      PS4="${PS4% }:chroot: "
      if which etckeeper > /dev/null; then
        etckeeper commit -m "$git_commit_message"
      fi
EOF
  fi
)
