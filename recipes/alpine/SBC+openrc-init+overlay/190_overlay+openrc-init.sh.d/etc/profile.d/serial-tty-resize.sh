TTYResize() {
        [ -z "$1" ] || export TERM="$1"
        case "$(tty)" in
                /dev/ttyS[0-9] | /dev/ttyGS[0-9] | /dev/ttyAMA[0-9] )
                        _STTY_=yes
                        f__resize() {
                                local rs=$?
                                [ "$_STTY_" = yes ] || \
                                        return $rs
                                local oIFS="$IFS"
                                IFS=$';\x1B['
                                read -p $'\x1B7\x1B[r\x1B[999;999H\x1B[6n\x1B8' -d R -rst 0.5 _ _ LINES COLUMNS _ < /dev/tty && \
                                stty cols $COLUMNS rows $LINES
                                IFS="$oIFS"
                                return $rs
                        }
                        PS1="$PS1"'$(f__resize)'
                        ;;
        esac
}
