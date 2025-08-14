PS1='\u @ \h$(__PS1_ExitCode)$(__PS1_GitStat) > \w > '
alias r="exec sudo -"

# start a log that can be interupted with ^C per default
#case "$(tty)" in
#  /dev/ttyS0 ) log ;;
#esac
