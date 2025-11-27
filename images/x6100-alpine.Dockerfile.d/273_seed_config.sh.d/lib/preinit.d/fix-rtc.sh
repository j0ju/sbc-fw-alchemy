( cd /sys/class/rtc/rtc0/device/driver
  for i in *; do
    [ -d $i ] || continue
    case "$i" in bind | unbind | uevent ) continue;; esac
    echo $i > unbind
  done
) || :

( cd /sys/class/rtc/rtc1/device/driver
  for i in *; do
    case "$i" in bind | unbind | uevent ) continue;; esac
    [ -d $i ] || continue
    echo $i > unbind
    while [ -c /dev/rtc1 ]; do
      sleep 1
    done
    echo $i > bind
  done
) || :

rm -f /dev/rtc /dev/rtc0
ln -s rtc1 /dev/rtc0
ln -s rtc1 /dev/rtc
