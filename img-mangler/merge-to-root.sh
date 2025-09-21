#!/busybox.static sh
set -eu
#set -x
BB=/busybox.static

#- /handle /etc with care
#  do this as early as possible to retain acls and xattrs for /etc
if [ -d /target/etc ]; then
  tar cf - --xattrs --acls --numeric-owner -C /target etc | \
    tar xf - -C / --acls --xattrs --exclude=etc/resolv.conf --exclude=etc/hosts --exclude=etc/hostname
  rm -rf /target/etc
fi

#- handle directories in /
for f in /*; do
  case "$f" in
    /src | /etc | /target ) continue ;; # ignore
    /busybox.static ) continue ;;
  esac

  if $BB awk '$0=$2' /proc/mounts | $BB grep "^$f$"; then
    $BB rm -rf /target/$f
    continue
  fi

  $BB rm -rf "$f"
  if [ -d "/target/$f" ]; then
    $BB mv "/target/$f" /
  fi
done

for f in /target/*; do
  case "$f" in
    */lost+found ) continue ;;
  esac
  $BB mv "$f" /
done

$BB rm -rf /target
