# - /etc/profile.d/usr-local.sh -
for i in \
  /usr/local/sbin \
  /usr/local/bin; \
do
  [ -d "$i" ] || continue
  export PATH="$i:$PATH"
done
