* (/) default netconfig
    * (/) dhcpv4
    * (/) fe80::bc
    * (/) 169.254.23.14
    * (/) dns can be set manually via openresolv/resolvconf
    * dhcpv6 ?
* logging
    * (/) local logging
    * if remote logging is wanted start rsyslogd with templated config
* bmcd
  * (/) otg works
  * (/) tpi works
  * (!) fix WebIF authentication
    * seems to have issues with alpines /etc/shadow, need to investigate further
  * properly build bmc 
* (/) chrony
  * start with no ressource and add them dynamically via chronyc ?
* add basic firewall
* (/) moved home dir of root to /run, for less writes on MMC/SD
    * copy on boot from /root/.[!.]* to /run

* (/) initialize OTG properly

* investigate stack traces at boot
```
[    0.072901] ------------[ cut here ]------------
[    0.072955] WARNING: CPU: 1 PID: 1 at drivers/clk/sunxi-ng/ccu_common.c:155 sunxi_ccu_probe+0x184/0x1b8
[    0.073016] No max_rate, ignoring min_rate of clock 6 - pll-periph0-div3
[    0.073041] Modules linked in:
[    0.073066] CPU: 1 PID: 1 Comm: swapper/0 Not tainted 6.8.12 #1
[    0.073095] Hardware name: Generic DT based system
[    0.073125]  unwind_backtrace from show_stack+0x10/0x14
[    0.073167]  show_stack from dump_stack_lvl+0x54/0x68
[    0.073208]  dump_stack_lvl from __warn+0x74/0xbc
[    0.073248]  __warn from warn_slowpath_fmt+0xb0/0x140
[    0.073288]  warn_slowpath_fmt from sunxi_ccu_probe+0x184/0x1b8
[    0.073330]  sunxi_ccu_probe from devm_sunxi_ccu_probe+0x4c/0x80
[    0.073376]  devm_sunxi_ccu_probe from sun20i_d1_ccu_probe+0xf0/0x11c
[    0.073421]  sun20i_d1_ccu_probe from platform_probe+0x58/0xa8
[    0.073467]  platform_probe from really_probe+0x130/0x29c
[    0.073510]  really_probe from __driver_probe_device+0x16c/0x18c
[    0.073550]  __driver_probe_device from driver_probe_device+0x38/0xb4
[    0.073592]  driver_probe_device from __driver_attach+0xe8/0xfc
[    0.073632]  __driver_attach from bus_for_each_dev+0x84/0xc4
[    0.073671]  bus_for_each_dev from bus_add_driver+0xa0/0x1b4
[    0.073709]  bus_add_driver from driver_register+0xb8/0x100
[    0.073749]  driver_register from do_one_initcall+0x74/0x1fc
[    0.073789]  do_one_initcall from kernel_init_freeable+0x198/0x1dc
[    0.073831]  kernel_init_freeable from kernel_init+0x14/0x12c
[    0.073872]  kernel_init from ret_from_fork+0x14/0x28
[    0.073908] Exception stack(0xc8815fb0 to 0xc8815ff8)
[    0.073935] 5fa0:                                     00000000 00000000 00000000 00000000
[    0.073970] 5fc0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
[    0.074002] 5fe0: 00000000 00000000 00000000 00000000 00000013 00000000
[    0.074027] ---[ end trace 0000000000000000 ]---
[    0.074070] ------------[ cut here ]------------
[    0.074093] WARNING: CPU: 1 PID: 1 at drivers/clk/sunxi-ng/ccu_common.c:155 sunxi_ccu_probe+0x184/0x1b8
[    0.074142] No max_rate, ignoring min_rate of clock 9 - pll-video0
[    0.074164] Modules linked in:
[    0.074186] CPU: 1 PID: 1 Comm: swapper/0 Tainted: G        W          6.8.12 #1
[    0.074218] Hardware name: Generic DT based system
[    0.074240]  unwind_backtrace from show_stack+0x10/0x14
[    0.074277]  show_stack from dump_stack_lvl+0x54/0x68
[    0.074313]  dump_stack_lvl from __warn+0x74/0xbc
[    0.074352]  __warn from warn_slowpath_fmt+0xb0/0x140
[    0.074389]  warn_slowpath_fmt from sunxi_ccu_probe+0x184/0x1b8
[    0.074430]  sunxi_ccu_probe from devm_sunxi_ccu_probe+0x4c/0x80
[    0.074476]  devm_sunxi_ccu_probe from sun20i_d1_ccu_probe+0xf0/0x11c
[    0.074520]  sun20i_d1_ccu_probe from platform_probe+0x58/0xa8
[    0.074562]  platform_probe from really_probe+0x130/0x29c
[    0.074603]  really_probe from __driver_probe_device+0x16c/0x18c
[    0.074643]  __driver_probe_device from driver_probe_device+0x38/0xb4
[    0.074685]  driver_probe_device from __driver_attach+0xe8/0xfc
[    0.074725]  __driver_attach from bus_for_each_dev+0x84/0xc4
[    0.074763]  bus_for_each_dev from bus_add_driver+0xa0/0x1b4
[    0.074800]  bus_add_driver from driver_register+0xb8/0x100
[    0.074839]  driver_register from do_one_initcall+0x74/0x1fc
[    0.074878]  do_one_initcall from kernel_init_freeable+0x198/0x1dc
[    0.074918]  kernel_init_freeable from kernel_init+0x14/0x12c
[    0.074958]  kernel_init from ret_from_fork+0x14/0x28
[    0.074993] Exception stack(0xc8815fb0 to 0xc8815ff8)
[    0.075019] 5fa0:                                     00000000 00000000 00000000 00000000
[    0.075053] 5fc0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
[    0.075085] 5fe0: 00000000 00000000 00000000 00000000 00000013 00000000
[    0.075110] ---[ end trace 0000000000000000 ]---
[    0.075148] ------------[ cut here ]------------
[    0.075169] WARNING: CPU: 1 PID: 1 at drivers/clk/sunxi-ng/ccu_common.c:155 sunxi_ccu_probe+0x184/0x1b8
[    0.075217] No max_rate, ignoring min_rate of clock 12 - pll-video1
[    0.075240] Modules linked in:
[    0.075260] CPU: 1 PID: 1 Comm: swapper/0 Tainted: G        W          6.8.12 #1
[    0.075292] Hardware name: Generic DT based system
[    0.075314]  unwind_backtrace from show_stack+0x10/0x14
[    0.075351]  show_stack from dump_stack_lvl+0x54/0x68
[    0.075387]  dump_stack_lvl from __warn+0x74/0xbc
[    0.075425]  __warn from warn_slowpath_fmt+0xb0/0x140
[    0.075462]  warn_slowpath_fmt from sunxi_ccu_probe+0x184/0x1b8
[    0.075503]  sunxi_ccu_probe from devm_sunxi_ccu_probe+0x4c/0x80
[    0.075548]  devm_sunxi_ccu_probe from sun20i_d1_ccu_probe+0xf0/0x11c
[    0.075591]  sun20i_d1_ccu_probe from platform_probe+0x58/0xa8
[    0.075633]  platform_probe from really_probe+0x130/0x29c
[    0.075674]  really_probe from __driver_probe_device+0x16c/0x18c
[    0.075714]  __driver_probe_device from driver_probe_device+0x38/0xb4
[    0.075756]  driver_probe_device from __driver_attach+0xe8/0xfc
[    0.075796]  __driver_attach from bus_for_each_dev+0x84/0xc4
[    0.075834]  bus_for_each_dev from bus_add_driver+0xa0/0x1b4
[    0.075871]  bus_add_driver from driver_register+0xb8/0x100
[    0.075910]  driver_register from do_one_initcall+0x74/0x1fc
[    0.075949]  do_one_initcall from kernel_init_freeable+0x198/0x1dc
[    0.075988]  kernel_init_freeable from kernel_init+0x14/0x12c
[    0.076028]  kernel_init from ret_from_fork+0x14/0x28
[    0.076063] Exception stack(0xc8815fb0 to 0xc8815ff8)
[    0.076089] 5fa0:                                     00000000 00000000 00000000 00000000
[    0.076123] 5fc0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
[    0.076156] 5fe0: 00000000 00000000 00000000 00000000 00000013 00000000
[    0.076180] ---[ end trace 0000000000000000 ]---
[    0.076224] ------------[ cut here ]------------
[    0.076245] WARNING: CPU: 1 PID: 1 at drivers/clk/sunxi-ng/ccu_common.c:155 sunxi_ccu_probe+0x184/0x1b8
[    0.076293] No max_rate, ignoring min_rate of clock 16 - pll-audio0
[    0.076316] Modules linked in:
[    0.076336] CPU: 1 PID: 1 Comm: swapper/0 Tainted: G        W          6.8.12 #1
[    0.076368] Hardware name: Generic DT based system
[    0.076390]  unwind_backtrace from show_stack+0x10/0x14
[    0.076427]  show_stack from dump_stack_lvl+0x54/0x68
[    0.076463]  dump_stack_lvl from __warn+0x74/0xbc
[    0.076501]  __warn from warn_slowpath_fmt+0xb0/0x140
[    0.076538]  warn_slowpath_fmt from sunxi_ccu_probe+0x184/0x1b8
[    0.076579]  sunxi_ccu_probe from devm_sunxi_ccu_probe+0x4c/0x80
[    0.076625]  devm_sunxi_ccu_probe from sun20i_d1_ccu_probe+0xf0/0x11c
[    0.076668]  sun20i_d1_ccu_probe from platform_probe+0x58/0xa8
[    0.076710]  platform_probe from really_probe+0x130/0x29c
[    0.076751]  really_probe from __driver_probe_device+0x16c/0x18c
[    0.076791]  __driver_probe_device from driver_probe_device+0x38/0xb4
[    0.076833]  driver_probe_device from __driver_attach+0xe8/0xfc
[    0.076873]  __driver_attach from bus_for_each_dev+0x84/0xc4
[    0.076911]  bus_for_each_dev from bus_add_driver+0xa0/0x1b4
[    0.076948]  bus_add_driver from driver_register+0xb8/0x100
[    0.076987]  driver_register from do_one_initcall+0x74/0x1fc
[    0.077026]  do_one_initcall from kernel_init_freeable+0x198/0x1dc
[    0.077065]  kernel_init_freeable from kernel_init+0x14/0x12c
[    0.077105]  kernel_init from ret_from_fork+0x14/0x28
```

