# - /etc/profile.d/PS1.sh -
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
PS1='\h$(__PS1_ExitCode)$(__PS1_GitStat) > \w > '
