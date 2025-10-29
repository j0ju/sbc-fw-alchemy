#- user convinience for RO/RW /-filesystem
  __PS1_RootFsMode() {
    local MODE="$( < /proc/mounts awk -F '[ ,]' '$1 !~ "^root(fs)?" && $2 == "/" {print toupper($4)}' )"
	case "$MODE" in
	  RW ) echo " | $TXTBLD$TXTBLU$MODE$TXTRST" ;;
	esac
  }

  __PS1_GitStat() {
    local GIT_BRANCH="$(git rev-parse --abbrev-ref HEAD 2> /dev/null)"
    if [ -n "$GIT_BRANCH" ]; then
      git status -s | head | grep ^ > /dev/null && GIT_BRANCH=$GIT_BRANCH:dirty
      echo " > ${TXTYLW}($TXTRST$GIT_BRANCH$TXTYLW)$TXTRST"
    fi
  }
  __PS1_ExitCode() {
    local rs=$?
    local out=""
    case "$rs" in
	    0 | "" ) ;;
  	  * ) out=" | ${TXTRED}?$rs$TXTRST"
	  esac
  	echo -e "$out"
  }
  __PS1_USER='\u'
  if [ "$USER" = root ]; then
    __PS1_USER="${TXTRED}"'\u'"$TXTRST"
  fi
  #PS1='\h$(__PS1_ExitCode)$(__PS1_GitStat) > \w > '
  PS1='$__PS1_USER@\h$(__PS1_ExitCode)$(__PS1_GitStat) > \w > '
  #PS1='\h$(__PS1_RootFsMode)$(__PS1_ExitCode)$(__PS1_GitStat) > \w > '
  #alias RO="root-ro"
  #alias RW="root-rw"
#
