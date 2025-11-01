# - /etc/profile.d/bash_completion.sh -
case "$-" in
  *i* ) [ -f /etc/bash/bash_completion.sh ] && . /etc/bash/bash_completion.sh ;;
esac

# vim: ts=2 sw=2 et ft=sh
