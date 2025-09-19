#!/bin/sh
# (C) 2025 Joerg Jungermann, GPLv2 see LICENSE
set -eu

git clone https://github.com/ifupdown-ng/ifupdown-ng.git /ifupddown-ng-git
cp /ifupddown-ng-git/executors/linux/* /target/usr/libexec/ifupdown-ng
chmod 0755 /target/usr/libexec/ifupdown-ng/*
