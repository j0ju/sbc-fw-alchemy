#!/bin/sh -e
# - shell environment file for run-parts scripts in this directory
# (C) 2024-2025 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
#set -x

# remove applet links to busybox if we have a real binary
chroot /target /bin/sh -eu << 'EOF'
  applet=busybox
  srch="$(echo "$PATH" | sed -r -e 's#/?(:|$)#/'"$applet"' #g')"
  bbs="$(ls $srch 2> /dev/null || :)"

  for bb in $bbs; do
    bb="$(readlink -f $bb)"
    $bb --list | while read applet; do
      srch="$(echo "$PATH" | sed -r -e 's#/?(:|$)#/'"$applet"' #g')"
      files="$(ls $srch 2> /dev/null || :)"
      bbexe=
      nonbbexe=

      for f in $files; do
        dst="$(readlink -f "$f")"
        if [ "$dst" = "$bb" ]; then
          bbexe="$f"
        else
          nonbbexe="$nonbbexe $f"
        fi
      done
      if [ -n "$bbexe" ] && [ -n "$nonbbexe" ]; then
        echo "$applet:$bb $bbexe << $nonbbexe"
        rm -vf $bbexe
      fi
    done
  done
EOF

# in Alpine 3.22 klogd user seems to be missing
chroot /target grep ^klogd: /etc/passwd || \
  chroot /target \
    adduser -h /dev/null -g klogd -s /sbin/nologin -S -u 103 -G nobody klogd

# vim: set ts=2 sw=2 et
