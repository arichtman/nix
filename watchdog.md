# Watchdog

BIOS has an option to enable TCO but no timer settings.
`ipmitool` can't locate and IPMI devices (`/dev/ipmi*`).
`wdctl` fails similarly, finding no default device (`/dev/watchdog0`).
`iTCO_wdt` seems to be the kernel module for watchdog.
There's a `watchdog-mux.service` but fails for same reason as `wdctl`.
Loading `wdat_wdt` module seems to add a device but watchdog-mux fails cause it's busy.
`systemd-analyze cat-config modprobe.d` and `modprobe -c` shows them blacklisted...

Timeout settings weren't coming successfully from adding module parameters to either `modprobe.d` or during `modprobe` calls.
Editing the `system.conf.d` file and running `systemctl daemon-reexec` did take the changes.

```
modprobe wdat_wdt timeout=30
modinfo wdat_wdt
modprobe --show-depends wdat_wdt
```

/etc/systemd/system.conf.d/10-watchdog.conf

```
[Manager]
RuntimeWatchdogSec=300
#RuntimeWatchdogPreSec=off
#RuntimeWatchdogPreGovernor=
#RebootWatchdogSec=10min
#KExecWatchdogSec=off
WatchdogDevice=/dev/watchdog
```

/etc/modprobe.d/watchdog.conf

```
options iTCO_wdt nowayout=1 heartbeat=30
options wdat_wdt timeout=30
#options softdog nowayout=1
```

/etc/modules-load.d/watchdog.conf

```
iTCO_wdt
wdat_wdt
```

```
modprobe ipmi_devintf
modprobe ipmi_msghandler
# This fails cause no device
modprobe ipmi_si
```

- [Arch wiki about watchdogs](https://wiki.archlinux.org/title/Improving_performance#Watchdogs)
- [Arch wiki kernel modules](https://wiki.archlinux.org/title/Kernel_module)
- [Thread about disabling it](https://www.reddit.com/r/archlinux/comments/1124b9a/unable_to_disable_watchdog/)
- [`wdctl` man page](https://www.man7.org/linux/man-pages/man8/wdctl.8.html)
- [Linux kernel docs](https://www.kernel.org/doc/html/v6.8/admin-guide/lockup-watchdogs.html)
- [Post about hw one](https://aus.social/@Unixbigot/112962997893280387)
- [troubleshooting post](https://www.baeldung.com/linux/watchdog-message-explained)
- [Watchdog post](https://forum.proxmox.com/threads/watchdog-will-not-trigger-on-intel-system.152238/)
- [IPMI watchdog post](https://advantech-ncg.zendesk.com/hc/en-us/articles/360028285872-How-to-configure-the-BMC-watchdog-function-using-ipmitool)
