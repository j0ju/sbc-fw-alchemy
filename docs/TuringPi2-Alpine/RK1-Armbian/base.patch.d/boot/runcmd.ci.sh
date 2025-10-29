#!/bin/sh
PS4="${0##*/}: "
trap `exit $?` EXIT
set -ex

#- setup
  gid_ADMIN_new=923
  uid_USER_new=1000
  gid_USER_new=1000

#- install etckeeper
  apt-get install -y etckeeper

#- rearrange uids & gids
  gid_ADMIN=$(< /etc/group awk -F: '$1=="admin" {print $3}')
  if [ "${gid_ADMIN:-0}" -ge 1000 ]; then
    sed -i -e "/^admin:/ s|:$gid_ADMIN:|:$gid_ADMIN_new:|" /etc/group
    : > /var/run/reboot-required
  fi
  
  uid_USER=$( id -u 1000 )"
  gid_USER=$( id -g 1000 )"
  if [ "${gid_USER:-0}" -gt 1000 ]; then
    gid_ADMIN_new=923
    sed -i -e "s|:$gid_ADMIN:|:$gid_ADMIN_new:|" /etc/group
  
    while IFS=: read -r n pw uid gid r; do
      if [ "$uid" -ge 1000 ]; then
        deluser --remove-home "$n"
      fi
    done < /etc/passwd
    while IFS=: read -r n pw gid members; do
      if [ "$gid" -ge 1000 ]; then
        delgroup "$n" || :
      fi
    done < /etc/group
  
    : > /var/run/reboot-required
  fi
  
  pwck -s
  grpck -s

#- resize /dev/mmcblk0 
  #  MAYBE: find rootdev dynamicly for other use-cases
  PT_old="$(sfdisk -d /dev/mmcblk0 | md5sum -)"
  KPART_old="$(md5sum /proc/partitions)"
  sfdisk -d /dev/mmcblk0 | \
    sed -r -e '$ s|, size=[0-9 ]*,|,|' | \
    sfdisk /dev/mmcblk0 --force
  
  PT_new="$(sfdisk -d /dev/mmcblk0 | md5sum -)"
  if [ ! "$PT_old" = "$PT_new" ]; then
    partx -u /dev/mmcblk0
    KPART_new="$(md5sum /proc/partitions)"
    if [ "$KPART_old" = "$KPART_new" ]; then
      : > /var/run/reboot-required
    fi
    ROOT_DEV=$(findmnt / -n -o SOURCE)
    FS_TYPE=$(findmnt / -n -o FSTYPE)
    
    case "$FS_TYPE" in
      ext[234] )
        resize2fs "$ROOT_DEV"
        ;;
      * )
        echo "unknown fs type '$FS_TYPE'" >&2
        exit 1
        ;;
    esac
  fi

#- reboot if needed, with again a fresh cloud init-run
if [ -f /var/run/reboot-required ]; then
  apt-get clean
  cloud-init clean # do this now only in case of a needed reboot
  reboot
fi

#- config locales
  sed -i -n -r -e "/(en_GB|en_US|de_DE|en_DK)\.UTF-8/ s/#? *// p" \
    /etc/locale.gen 
  locale-gen 

#- install packages
  apt-get install -y \
    mc screen tmux screen \
    tcpdump ifstat \
    mtr-tiny iputils-ping iputils-arping inetutils-telnet traceroute mtr-tiny \
    bridge-utils vlan net-tools \
    tcpdump strace ltrace mtr-tiny traceroute \
    strace ltrace \
    vim-nox \
    busybox \
    ssh \
    make \
    gpm \
    flashrom testdisk pigz pixz pv \
    minicom lrzsz \
    f2fs-tools exfatprogs gddrescue lzop \
    podman podman-compose podman-docker podman-toolbox \
    qemu-user:arm64 qemu-user-static:arm64 qemu-utils:arm64 \
    qemu-system \
    #

#- deinstall rsyslog, we use journal only or specifc log filess
  PKGs_to_remove=
  PKGs_to_remove="$PKGs_to_remove rsyslog"
  PKGs_to_remove="$PKGs_to_remove nano"
  PKGs_to_remove="$PKGs_to_remove armbian-config"
  for p in $PKGs_to_remove; do
    ! p=$(dpkg -l $p | awk '$1 == "ii" && $0=$2' | grep ^) || \
      apt-get remove -y --purge $p
  done
  ! p=$(dpkg -l linux-headers* | awk '$1 == "ii" && $0=$2' | grep ^) || \
    apt-get remove -y --purge $p
  apt-get autoremove -y --purge

#- upgrade the rest
  apt-get upgrade -y

#- cleanup
  apt-get clean
  rm -rf \
    /var/log/syslog \
    /var/log/messages \
    /var/log/auth.log \
    /var/log/cron.log \
    /var/log/kern.log \
    /var/log/mail.log \
    /var/log/user.log \
    /var/log/armbian-hardware-monitor.log \
    /var/log/armbian-ramlog.log \
    /var/log/runit \
    /var/log.hdd \
    #
    
#- reboot if needed, with again a fresh cloud init-run
if [ -f /var/run/reboot-required ]; then
  apt-get clean
  cloud-init clean # do this now only in case of a needed reboot
  reboot
fi
fstrim / || :
fstrim /boot || :

if [ -f /root/.ssh/authorized_keys ] && homes=$(ls -d /home/*); then
  for home in $homes; do
    mkdir -p "$home/.ssh"
    user="${home##*/}"
    cp /root/.ssh/authorized_keys "$home/.ssh"/authorized_keys
    chown "$user:" "$home/.ssh"
    chmod 744 "$home/.ssh"
    chmod 644 "$home/.ssh/authorized_keys"
  done
fi
