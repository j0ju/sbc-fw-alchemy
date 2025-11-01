#- user convinience for RO/RW /-filesystem
__PS1_RootFsMode() {
  [ -r /proc/mounts ] || return 0
  local MODE="$( < /proc/mounts awk -F '[ ,]' '$1 !~ "^root(fs)?" && $2 == "/mmc" {print toupper($4)}' )"
  case "$MODE" in
    #RO ) echo -e " | $TXTBLD$TXTBLU$MODE$TXTRST" ;;
    RW ) echo -e " | $TXTBLD$TXTRED$MODE$TXTRST" ;;
  esac
}

PS1='\h$(__PS1_RootFsMode)$(__PS1_ExitCode)$(__PS1_GitStat) > \w > '
