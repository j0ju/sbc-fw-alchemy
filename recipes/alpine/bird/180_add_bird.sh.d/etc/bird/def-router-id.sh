( 
cat << EOF
# automatically generated on $(date)
router id $(head -c 4 /dev/urandom | hexdump -C | ( read _ a b c d _; echo $((0x$a%16+240)).$((0x$b)).$((0x$c)).$((0x$d)) ) );
EOF
) | tee def-router-id.conf
