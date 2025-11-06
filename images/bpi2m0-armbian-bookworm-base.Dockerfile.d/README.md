This image switches to systemd completely for
 * network (DHCP)
 * console config
 * timesync
 * resolve

Only serial console are activated.
There is no root passwort set, but 
 * serial console are on password less login on ttyS0 and the OTG serial
You might consider this a security flaw: it is not!
If an attacker has access to the hardware you have lost anyways.

Configure a proper user and password on bootstrap and of you like, 
disable password less login on serial consoles.
