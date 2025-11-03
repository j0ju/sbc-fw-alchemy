#!/bin/sh
set -eu
set -x

via="$(ip -6 r get default 2> /dev/null | grep -oE " via [^ ]+" | { read _ v; echo $v; })"
case "$via" in
  fe80:* )
    dev="$(ip -6 r get default 2> /dev/null | grep -oE " dev [^ ]+" | { read _ v; echo $v; })"
    via="$via%$dev"
esac

ping -q -c 3 -i .1 -W 1 $via > /dev/null
exit $?
