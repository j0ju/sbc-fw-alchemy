#!/bin/bash
# nv-init-int.sh
#  - NVidia is providing an internal hook for overrides and development
#    originally used internally, found during reversing the flashing process
#
#    We hook into PID1 /init (shell script) and override shell functions
#    eg. process_bash_reboot to be used when no valid rootdev is found
#    and extend possibilieties for rootfs
process_bash_reboot () {
  : # HOOK start
  local root="$( grep -Eo "root=[^ ]+" /proc/cmdline | sed -r -e 's/^[^=]+=//' )"
  case "${root}" in
    live:* ) root_live ;;
    initrd ) root_initrd ;;
  esac
  : # HOOK end

  : # mostly original rest of original function
  if [ -x "/usr/sbin/nvluks-srv-app" ]; then # Disable luks-srv TA before entering bash
    nvluks-srv-app -n > /dev/null 2>&1;
  fi

  # Reboot directly if bash is disabled
  if [ -e "/etc/.disable_initrd_bash" ]; then
    echo "Bash is disabled, rebooting system..." > /dev/kmsg;
    reboot;
  fi;

  process_console_input "ttyTCU0"
  process_console_input "ttyTHS1"

  # Reboot if no input from any tty* console
  echo "Rebooting system..." > /dev/kmsg;
  reboot;
  }

PS4="${0}[$$]: "

load_network_drv() {
  local PS4="${PS4%%:*}::load_network_drv: "
  ip link set up dev lo
  # copied from /init / rootdev=nfs

  # Use r8168.ko (downstream) if present, else use r8169.ko (upstream)
  modprobe -v r8168 || modprobe -v r8169
  modprobe -v r8126
  if [[ "${version}" != *5\.10* ]]; then
    # Use nvethernet.ko (downstream) if present,
    # else use dwmac-tegra.ko (upstream)
    modprobe -v nvethernet || modprobe -v dwmac-tegra
    modprobe -v pcie-tegra194;
    modprobe -v phy-tegra194-p2u;
  fi
  }

net_hw_init() {
  local PS4="${PS4%%:*}::net_hw_init: "

  load_network_drv

  # wait for eth0 to appear
  local timeout=13;
  while [ ${timeout} -gt 0 ]; do
    if [ -d /sys/class/net/eth0 ]; then
      break
    fi
    timeout=$((timeout-1));
    sleep 1
  done

  dhclient -d eth0 & DHCLIENT=$!
  /sbin/udevd & UDEV=$!

  # wait for defailt route
  local timeout=13;
  while [ ${timeout} -gt 0 ]; do
    if ip -4 r sh | grep default; then
      break
    fi
    timeout=$((timeout-1));
    sleep 1
  done
  if ! ip -4 r sh | grep default; then
    return
  fi

  modprobe -v nvme

  udevadm trigger
  udevadm settle

  kill -9 $DHCLIENT
}

syslogd() {
  local PS4="${PS4%%:*}::syslogd: "
  SYSLOGD=
  mkdir -p /var/log
  /bin/busybox syslogd -C256 -S -t -n & SYSLOGD="$SYSLOGD $!"
  /bin/busybox klogd -n               & SYSLOGD="$SYSLOGD $!"
}

sshd() {
  local PS4="${PS4%%:*}::sshd: "
  ssh-keygen -A
  passwd -u root
  echo root:root | chpasswd
  mkdir -p /dev/pts
  mount -t devpts devpts /dev/pts
  > /var/log/lastlog
  /sbin/sshd -D & SSHD=$!
}

root_live() {
  local PS4="${PS4%%:*}::root_live: "
set -x
  net_hw_init
  live_url="${root#live:}"
  # TODO
set +x
  }

root_initrd() {
  local PS4="${PS4%%:*}::root_initrd: "
set -x
  hostname -F /etc/hostname
  syslogd
  net_hw_init
  sshd
  exec /bin/busybox init
set +x
  }



# vim: ts=2 sw=0 et foldmethod=indent
