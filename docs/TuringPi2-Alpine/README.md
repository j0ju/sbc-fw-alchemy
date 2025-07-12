# TuringPi2 - Alpine

## Quickstart / Making of

 * It compiles the kernel via buildroot from official sources with a slighly different config.
 * Kernel an modules are then merged with an alpine/armv7 userland.
 * Kernel and read-only rootfs reside in partition 1 / ext4 mounted ad /rom
 * On first boot a second partition is created with filesystem LABEL=tpi2data (f2fs currently) mounted as /mmc
 * read-write root filesystem is created with overlayfs with base /rom and read-write store /mmc/overlay

 Note: The default secret is the same as from the official firmware. Change it!

## Tools

### minicom
Minicom is per defautl configured with CTRL-X as comand key. CTRL-X CTRL-X exits.

The following command Will bring up the serial console of the node 1.
```
minicom node1
minicom n1
minicom 1
```
The same would haben with node2,n3,4 for the other nodes.

Note: output and input of the serial is not garbled as per default the serial API in bmcd is wrapped/disabled so it does not interfere.
Idea: The otherway around it would allow eg gotty or similar to be used as web terminal server.

### `pwr`, `on`, `off`, `msd`

These handy wrappers allow doing some node operations, wrapping tpi functionality, but quicker accessible.

 * `pwr - Display current node status
 * `on NODE` - where node is [1234] eg. `on 1`
 * `off NODE`
 * `msd NODE` - pwrs the node on, an puts it into USB Boot/USB Storage mode

### `flash`
`flash` flashes an image file to a node.
```
flash IMG NODE
```
IMG is an image file. It can be xz, zst or gz compressed.
In case of CM4 it can be an tar of an rootfile system (generated with this toolchain, too),
so that rootfs can be something different than ext4 (eg f2fs, btrfs, ...).

### `PatchNode`

...TBD...

### Alpine

This uses alpine openrc, with per default
 * ssh
 * bmcd
 * avahi
enabled.

Cron is not enabled per default.
It can be enabled on bootup and started with
```
rc-update add crond default
rccrond start
```

The package manager is `apk`.

Handy tools:

 * `apk add PKG`
 * `apk del PKG`
 * `apk search REGEX`
 * `apk info`
 * `apk info -L`

 * `rc-update` - display curent services enablked on system start.
 * `rc-update add SVC default` - enables start of service SVC at boot.
 * `rc-update del SVC default` - removes SVC from boot up services.

 * `update-rc` - creates aliases for all services in /etc/init.d/SVC to rcSVC, eg. rcsshd, rcnetwork.

### `etckeeper`

On /mmc

The `/etc` directory is backed up by `etckeeper` which uses `git` to version control any changes.
If you install packages or change configs with `apk` it will commit changes before and after package install.

### Logging

 * bmcd logs to /tmp/bmcd.DATE.log and rotates itself(?), ramdisk?
 * syslog and kernel log goes to busybox log ringbuffer of 256k.
 * central logging can be enabled via rsyslog.

Busybox syslog is also forwarding to `[::1]:514/udp`.
See `/etc/rsyslog.conf`. There you find a place where to define the log target.
To enable rsyslog:
```
rc-update add rsyslog default
rcrsyslog start
```
Why this indirection, the busybox logformat is not wellformed, rsyslog is used to augement proper host
information from hostname and /etc/hosts.
Rsyslog in this config per default emits RSYSLOG_SyslogProtocol23Format.
https://www.rsyslog.com/doc/configuration/templates.html
This is close to RFC5424 which is understood by promtail and vector.

## Ideas

### Snapshots, backup, restore, factory-reset

If /mmc/overlay is a symbolic link to a directory, you can easyly do snapshots:
simply copy or use tar with xattr and acls to dump /mmc/overlay somewhere else.

The same way you can do backups or revert to different configs (eg environments).
simply change the target of symlink /mmc/overlay to the directory that should be used
as overlay from on next boot.

Factory-Reset: without loosing config?

### Organisation on disk `/mmc`

I prefer to put my images and content below:
 * `/mmc/RK1` - images and patches for RK1
 * `/mmc/CM4` - images and patches for CM4
 * `/mmc/TuringPi2` - scripts and development

 * `/mmc/overlay` - a symlink to `overlay.CURRENTRUNNINGSCNAPSHOT`
 * `/mmc/overlay.YOUNAMEIT` - overlay directories or snapshots. On dump or copy, copy ACL or XATTRS.

### Future
 * Use Gotty as terminal server
 * Create users node1 to node4 with ssh loggin that are only allowed to view the serial of a node.

## Known Issues

 * BMC OTA for now will not work or migh even break the system. Don't use it.
