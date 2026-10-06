#!/bin/sh -eu
PS4='> ${0##*/}: '
set -eu

. "$SRC/lib.sh"; init

cd "$DST"

# Install and configure irqbalance
# Hardware interrupt distribution over cores with Arch awareness
apt clean
apt update

# install minimum required finaries
apt-get install -y jq

# Configure timezone - global standard
ln -sf /usr/share/zoneinfo/UTC /etc/localtime


# Add/Block default kernel drivers
echo "blacklist amdgpu" > /etc/modprobe.d/blacklist-amdgpu.conf
echo "blacklist nouveau" > /etc/modprobe.d/blacklist-nouveau.conf
echo "blacklist snd_hda_intel" > /etc/modprobe.d/blacklist-snd-intel.conf
echo "nvme_rdma" > /etc/modules-load.d/nvme.conf
echo "nbd" > /etc/modules-load.d/nbd.conf


# Configure default logrotate rules
cat > /etc/logrotate.d/rsyslog <<'EOF'
# Default config from ND-hypervisor image

/var/log/syslog
/var/log/mail.info
/var/log/mail.warn
/var/log/mail.err
/var/log/mail.log
/var/log/daemon.log
/var/log/kern.log
/var/log/auth.log
/var/log/user.log
/var/log/lpr.log
/var/log/cron.log
/var/log/debug
/var/log/messages
{
        rotate 4
        weekly
        size 1G
        missingok
        notifempty
        compress
        delaycompress
        sharedscripts
        postrotate
                /usr/lib/rsyslog/rsyslog-rotate
        endscript
}
EOF
chmod 444 /etc/logrotate.d/rsyslog


# Configure default iproute2 rules
cat > /etc/iproute2/rt_protos.d/nd-netagent.conf <<'EOF'
# Default config from ND-hypervisor image

# Reserved protocols
23 ndnetagent
EOF
chmod 444 /etc/iproute2/rt_protos.d/nd-netagent.conf


apt install -y irqbalance
systemctl enable irqbalance


# Ship sysctl settings
cat > /etc/sysctl.d/10-disable-rp-filter.conf <<'EOF'
# Default config from ND-hypervisor image

# Disable reverse-path filtering
net.ipv4.conf.default.rp_filter=0
net.ipv4.conf.all.rp_filter=0
EOF
chmod 444 /etc/sysctl.d/10-disable-rp-filter.conf

cat > /etc/sysctl.d/10-enable-forwarding.conf <<'EOF'
# Default config from ND-hypervisor image

# Enable IPv4 forwarding
net.ipv4.ip_forward=1

# Allow source addresses present locally as source address
net.ipv4.conf.all.accept_local=1

# Enable IPv6 forwarding
net.ipv6.conf.all.forwarding=1
EOF
chmod 444 /etc/sysctl.d/10-enable-forwarding.conf

cat > /etc/sysctl.d/10-icmp-errors-use-inbount-interface-address.conf <<'EOF'
# Default config from ND-hypervisor image

# Send ICMP errors from primary address of ingress interface
net.ipv4.icmp_errors_use_inbound_ifaddr=1
EOF
chmod 444 /etc/sysctl.d/10-icmp-errors-use-inbount-interface-address.conf

