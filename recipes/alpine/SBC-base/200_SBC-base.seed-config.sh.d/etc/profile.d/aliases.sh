# - /etc/profile.d/aliases.sh -

alias rL="__ETC_PROFILE_READ=no; __HOME_PROFILE_READ=no; . /etc/profile; [ -f ~/.profile ] && . ~/.profile"
alias rS="exec tx"
alias log="logread -F"

alias Faux="ps faux | awk '\$5!=0 && \$0 !~ \"awk\"'"
alias ip="ip -c"

dSH() {
  local f="$1"
  if which "$f"; then
    shift
    sh -x "$(which "$f")" "$@"
  fi
}
