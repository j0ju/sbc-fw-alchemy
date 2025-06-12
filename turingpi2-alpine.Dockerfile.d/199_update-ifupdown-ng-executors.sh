#!/bin/sh
set -eu

git clone https://github.com/ifupdown-ng/ifupdown-ng.git /ifupddown-ng-git
cp /ifupddown-ng-git/executor-scripts/linux/* /target/usr/libexec/ifupdown-ng
chmod 0755 /target/usr/libexec/ifupdown-ng/*
