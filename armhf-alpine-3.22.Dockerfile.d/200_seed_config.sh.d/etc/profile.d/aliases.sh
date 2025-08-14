# - /etc/profile.d/aliases.sh -

alias rL="__ETC_PROFILE_READ=no; . /etc/profile"
alias rS="exec tx"
alias log="logread -F"

alias Faux="ps faux | awk '\$5!=0 && \$0 !~ \"awk\"'"
alias ip="ip -c"
