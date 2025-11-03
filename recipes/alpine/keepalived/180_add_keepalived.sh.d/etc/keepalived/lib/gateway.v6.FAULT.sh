#!/bin/sh
if ! . /etc/keepalived/lib/chk_def_gateway.v6.sh; then
  ifdown mgmt -f; ifup mgmt
fi
