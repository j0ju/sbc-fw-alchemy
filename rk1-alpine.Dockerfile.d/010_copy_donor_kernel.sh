set -eu
umask 022

PS4='> ${0##*/}: '
#set -x

rm -rf /target/boot /target/lib/modules
cp -a /vanilla/lib/modules /target/lib/modules
cp -a /vanilla/boot /target/boot
chown -R 0:0 /target/boot/*
rm -f /target/boot/*.bmp
chown -R 0:0 /target/boot/*

cp -a /target.busybox.static /target/sbin/busybox.static

