# ~/.profile   |   ~/.bashrc   |   ~/.bash_profile

#- avoid loops
[ "$__HOME_PROFILE_READ" = yes ] && return 0
__HOME_PROFILE_READ=yes

# shell init tracing
#tty > /dev/null && echo "${BASH_SOURCE:-$HOME/.profile}[$$]"
#
#- include /etc/profile to be sure
[ ! -f /etc/profile ] || . /etc/profile

#- include /root/bin
#if [ -d /root/bin ]; then
#  PATH="/root/bin:$PATH"
#fi

#PS1='\u @ \h$(__PS1_ExitCode)$(__PS1_GitStat) > \w > '

# start a log that can be interupted with ^C per default
#case "$(tty)" in
#  /dev/ttyS0 ) log ;;
#esac
