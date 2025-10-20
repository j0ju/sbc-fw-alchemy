# - /etc/profile.d/PS1.sh -
#TXTBLK= # '\[\e[30m\]' # Black
#TXTRED= # '\[\e[31m\]' # Red
#TXTGRN= # '\[\e[32m\]' # Green
#TXTYLW= # '\[\e[1m\e[33m\]' # Yellow
#TXTBRN= # '\[\e[33m\]' # Brown
#TXTBLU= # '\[\e[34m\]' # Blue
#TXTPUR= # '\[\e[35m\]' # Purple
#TXTCYN= # '\[\e[36m\]' # Cyan
#TXTWHT= # '\[\e[37m\]' # White
#
#TXTREG= # '\[\e[0m\]'  # Regular
#TXTBLD= # '\[\e[1m\]'  # Bold
#TXTUND= # '\[\e[4m\]'  # Underline
#TXTBLN= # '\[\e[5m\]'  # Blink
#TXTINV= # '\[\e[7m\]'  # Inverse
#TXTRST= # '\[\e[0m\]'  # Text Reset

#CLRLINE='\[\e[K\]'
#
#BGBLK='\[\e[40m\]'   # Black
#BGRED='\[\e[41m\]'   # Red
#BGGRN='\[\e[42m\]'   # Green
#BGYLW='\[\e[43m\]'   # Yellow
#BGBLU='\[\e[44m\]'   # Blue
#BGPUR='\[\e[45m\]'   # Purple
#BGCYN='\[\e[46m\]'   # Cyan
#BGWHT='\[\e[47m\]'   # White
#
#CSRSAV='\[\e[s\]'     # Save CSR Pos
#CSRRST='\[\e[u\]'     # Restore CSR Pos
#CSRHOME='\[\e[1;1H\]'   # Set CSRPOS x/y=1/1

#- user convinience for RO/RW /-filesystem
__PS1_RootFsMode() {
  local MODE="$( < /proc/mounts awk -F '[ ,]' '$1 !~ "^root(fs)?" && $2 == "/mmc" {print toupper($4)}' )"
    case "$MODE" in
      #RO ) echo -e " | $TXTBLD$TXTBLU$MODE$TXTRST" ;;
      RW ) echo -e " | $TXTBLD$TXTRED$MODE$TXTRST" ;;
    esac
}

PS1='\h$(__PS1_RootFsMode)$(__PS1_ExitCode)$(__PS1_GitStat) > \w > '
