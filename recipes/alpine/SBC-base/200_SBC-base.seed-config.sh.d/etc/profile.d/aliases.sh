# - /etc/profile.d/aliases.sh -

alias rL="__ETC_PROFILE_READ=no; __HOME_PROFILE_READ=no; . /etc/profile; [ -f ~/.profile ] && . ~/.profile"
alias rS="exec tx"
alias log="logread -F"

alias Faux="ps faux | awk '\$5!=0 && \$0 !~ \"awk\"'"
alias ip="ip -c"
alias mc="mc -adX"

mcd() {
  __mcd_tmp="${TMPDIR:-/tmp}/.mcd$(tr -dc "a-zA-Z0-9.,:+-" < /dev/urandom | head -c32)"
  mc -P "$__mcd_tmp" "$@"
  cd "$( cat "$__mcd_tmp" 2> /dev/null && rm -f "$__mcd_tmp" )" 2> /dev/null
  unset __mcd_tmp
}
dSH() {
  local f="$1"
  if which "$f"; then
    shift
    sh -x "$(which "$f")" "$@"
  fi
}
