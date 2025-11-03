(
cat <<EOF
# roles/mesh: randomly salted on $(date)
define WIX_ASN = $(head -c4 /dev/random  | hexdump -C | (read _ a b c d _; echo 42$(( 0x${a#?}$b$c$d % 94967295 )) ));
EOF
) | tee def-w-ix-ASN.conf
