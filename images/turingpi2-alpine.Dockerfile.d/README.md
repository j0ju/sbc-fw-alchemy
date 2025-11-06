This is a Alpine based BMC linux for the Turing Machine Turing Pi2.

 * It currently only runs from SD card.
 * Credentials are the same as for original firmware.
 * bmcd
   * tpi works locally
   * is with a dirty hack ported to alpine (not nativly compiled, yet)
   * !!! bmcd webinterface has issues with authentication, probaly because /etc/shadow of alpine has different hash format, needs further investigation !!!
 * Network
   * VLANs and Bonding are supported, VLANs tested
   * supports VLANs with proper isolation
   * tagged and untagged on ge0/1 and node1/2/3/4
   * if DHCPv4 does not work provide per default access via link local addresses fe80::bc and 169.254.23.14
   * config below /etc/network/interfaces.d is structured in a way it can be easily modified by external programs like BMC
 * logging
   * is now done via busybox sysklogd and klogd for local logging
   * a rsyslog config for remote logging is prepared
     * this logging cascade is useful for having properly formatted syslog with hostname fields
 * config in etc is maintained via etckeeper

