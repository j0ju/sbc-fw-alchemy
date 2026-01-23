#!/bin/sh
set -eu
umask 022

GITDIR=      # ../fw-alchemy/
FORCE_BUILD= # no

[ -r ./config ] && . ./config

if [ -z "$GITDIR" ]; then
  echo "E: $GITDIR is not set, edit config" 1>&2
  exit 1
fi

if [ "$FORCE_BUILD" = yes ]; then
  ( cd "$GITDIR"
    rm -f output/*
    make
  )
fi

GITREV="$( cd "$GITDIR" ; git log --oneline HEAD^..HEAD | ( read id _; echo $id ) )"
GITURL="$( cd "$GITDIR" ; git remote show origin -n | awk '/Push/ && $0=$3 {print;exit 0}' )"

if echo "$GITURL" | grep git@ > /dev/null; then
  GITURL="$( echo "$GITURL" | sed -r -e 's1:1/1' -e 's|git@|https://|' -e 's/.git$//' )"
fi

mkdir -p "$GITREV"
rsync "$GITDIR"/output/* "$GITREV"
rmdir "$GITREV" 2> /dev/null || :

cat > index.html << EOF
<html>
<head>
  <title> releases for $GITURL </title>
  <link rel="stylesheet" href="style.css"/>
</head>
<body>
<h1> releases for $GITURL </h1>
<table>
<tr/>
  <th class="id"/> commit ID
  <th class="message"/> changes
EOF

( cd "$GITDIR"
  git log --oneline
) | while read id message; do
  type="release"
  ls "$id"/* 2> /dev/null 1>&2 || type=log
  echo "<tr/>"

  echo "<td class='id $type'/> $id"
  echo "<td class='$type'/>"
  if [ "$type" = "release" ]; then
    echo "<ul>"
    for i in "$id"/*; do
      case "$i" in
        *.sha256sum ) continue ;;
      esac
      [ -f "$i.sha256sum" ] || sha256sum "$i" > "$i.sha256sum"
      read sha256sum _ < "$i.sha256sum"
      echo "<li/><a href='$i'>${i##*/}</a><p class='sha256sum'>sha256: $sha256sum</p>"
    done
    echo "</ul>"
    echo "<p class="changes">changes</p>"
  fi
  echo "<p class="log"> $message</p>"
done >> index.html

echo "</table></body></html>" >> index.html
