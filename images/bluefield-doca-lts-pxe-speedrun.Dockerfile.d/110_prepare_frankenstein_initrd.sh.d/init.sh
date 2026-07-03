#!/bin/sh

# initrd init - small trampoline for starting BF2/3 flashin process via PXE, and moving the
# major downloads to Linux from formerly UEFI/grub
#  (110MB/s vs 300-600kb/s)

# FIXME: console output to hvc0 is broken in initrd?
#        what is missing/needed?
#        it is also broken in original initrd and starts around
#        initrd to rootfs change according to console output

#- config
#- pedantic thumb-screws
  #set -eu # currently off, as console output is broken

#- debugging, if needed
  PS4="${0}[$$]: "
  exec 1> /init.log 2>&1
  set -x

#- console log output if debugging is off / no set -x
  log() {
    echo "${PS4}$*" > /dev/hvc0
  }

#- emergency console fallback
  emergency_console() {
    rs=$?
    set +eu
    while :; do
      trap 'kill $pid' EXIT # HUP
      busybox nc -v -l -p 12345 -e /bin/sh & pid=$!
      #getty -i -n -l /bin/sh 115200 hvc0 screen & pid=$!
      wait
    done # & # <---- !!!
    while :; do
      trap 'kill $pid' EXIT # HUP
      wait
    done & # <---- !!!
    echo "${0}[$$]::emergency_console() $* (EXITCODE $rs)"
    PS4="${0}[$$]::emergency_console(): "
    echo ""
    log "--- emergency fall through console --- $0[$$]"
    env | sort
    log "---"
    mount
    log "--- emergency fall through console --- $0[$$]"
    echo ""
    # Q: open hvc0 as acting tty ...
    #    but do not close /dev/console, or the kernel panics, happens on some other "SBC"s
    exec 0</dev/hvc0 1>/dev/hvc0 2>/dev/hvc0 # 3</dev/console
    exec /bin/sh -il
  }
  trap emergency_console EXIT # HUP

log mount needed filesystems
  umask 022
  mkdir -p /dev /proc /sys /tmp /run
  mount -n -t proc proc /proc
  mount -n -t devtmpfs devtmpfs /dev
  mount -n -t sysfs sysfs /sys
  mount -n -t tmpfs tmpfs /tmp
  mount -n -t tmpfs tmpfs /run
  chmod 1777 /tmp

log start udev for coldplug/hardware discovery

#- syslog wrappers
#  SYSLOG_PIDS=
#  syslog_start() { /sbin/syslogd -n -C256 & SYSLOG_PIDS=$!; /sbin/klogd -n & SYSLOG_PIDS="$SYSLOG_PIDS $!"; sleep 3; }
#  syslog_stop() { kill $SYSLOG_PIDS || :; }
#  syslog_start

log start coldplug - hardware init
  /sbin/udevd & UDEVD=$!
  udevadm trigger

log from original initrd - /scripts/initrd-install
  #- emmc
  modprobe sdhci-of-dwcmshc
  modprobe dw_mmc-bluefield

  log init tmfifo
  modprobe mlxbf_tmfifo
  udevadm settle
  #- add IPv6 LinkLocal - for rescue nc on tmfifo_net0
  ip addr add fe80::bf/64 dev tmfifo_net0
  ip link set up dev tmfifo_net0

  #- start ipmi -> moved to original code
  #modprobe -a ipmi_msghandler ipmi_devintf i2c-mlxbf || :
  #modprobe ipmb_host slave_add=0x10 || :
  #echo ipmb-host 0x1011 > /sys/bus/i2c/devices/i2c-1/new_device || :

  #- watchdog and eMMC boot config
  #  insmod /mlx-bootctl.ko.zst || :
  #  insmod /sbsa_gwdt.ko.zst || :

  log init oob_net0
  # Q: missing module depedency?
  #[ 2497.239831] mdio_bus MLNXBF17:00:03: error -16 loading PHY driver module for ID 0x00221622
  #[ 2497.248277] mlxbf_gige MLNXBF17:00: Failed to register MDIO bus
  #[ 2497.254206] mlxbf_gige MLNXBF17:00: probe: mdio_probe failed: -EBUSY
  #[ 2497.260680] mlxbf_gige: probe of MLNXBF17:00 failed with error -16
  # A: yes, but no, mlxbf_gige needs MDIO subsystem and provider/driver to be present
  modprobe gpio-mlxbf2
  modprobe mlxbf_gige

log wait for coldplugging/Plug'n'Play to be finished
  udevadm settle
  kill $UDEVD

#- add IPv6 LinkLocal - for rescue console on oob_net0
  ip addr add fe80::bf/64 dev oob_net0
  ip link set up dev oob_net0

log init oob_net0
  udhcpc -i oob_net0 & UDHCPC=$!
  while ! ip r sh default | grep ^ -q; do sleep 1; done
  kill -9 $UDHCPC # kill hard so that udhcpc itself does not tear down the interface

# get bf_initrd_url= from kernel
  URL="$(grep -oE "bf_initrd_url=[^ ]+" < /proc/cmdline | { IFS="=" read _ v; echo $v; })"

  case "$URL" in
    http://* | https://* ) ;; # OK
    * )
      log "bf_img_url is not a valid $URL, HALT" >&2
      exit 1 # fail hard
      ;;
  esac

  case "$URL" in
    *.xz ) DECOMPRESSOR="unxz" ;;
    *.gz ) DECOMPRESSOR="gzip -d" ;;
  esac

log fetch image
  wget -O "/${URL##*/}" "$URL"

log pivot/exec to original initrd
  # IDEA:

  #   * remove my self, but keep the script for not confusing the sh/bash
  mv /init /init.trampoline
  mv /sbin/init /sbin/init.trampoline

  #   * just unpach overwrite and rexec my-overwriten self to /
  # unmount uneeded and let the next initrd do the work
  cd /
  umount * || :
  umount * || :
  umount * || :
  $DECOMPRESSOR < "/${URL##*/}" | cpio -i -d -u
  exec /init "$@"

# vim: set ft=shell ts=2 et sw=0 foldmethod=indent
