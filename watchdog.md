# Watchdog

## Proxmox

First, we need to enable the HW in BIOS.

BIOS has an option to enable TCO but no timer settings.
This is an Intel board so kernel module `iTCO_wdt` is the correct one.

Second, I think we need Kernel support.

`modinfo iTCO_wdt` looks like it's in the Kernel.
`systemd-analyze cat-config modprobe.d` and `modprobe -c` shows them blacklisted...
`wdctl` _should_ be showing status but `/dev/watchdog` is missing.
`dmesg` says NMI watchdog is enabled, but HA wiki says disable that.

I've set

```
/etc/default/pve-ha-manager
WATCHDOG_MODULE=iTCO_wdt
```

and

```
/etc/default/grub
GRUB_CMDLINE_LINUX_DEFAULT="quiet nmi_watchdog=0"
```

followed by `update-grub`.

Third, we need something configured to poke the watchdog.

There's a `watchdog-mux.service` but it's inactive(dead) and nothing in journalctl.

## VMs

1. Add `watchdog: model=i6300esb,action=reset` to the conf file in `/etc/pve/qemu-server/`.
1. Stop and start the VM.

## Leftover notes

`ipmitool` can't locate and IPMI devices (`/dev/ipmi*`) because that's for other manufacturers.

Loading `wdat_wdt` module seems to add a device but watchdog-mux fails cause it's busy.

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

> If you're using systemd then you probably want to set RuntimeWatchdogSec= in /etc/systemd/system.conf and let the init process take care of poking the watchdog.


- [Arch wiki about watchdogs](https://wiki.archlinux.org/title/Improving_performance#Watchdogs)
- [Arch wiki kernel modules](https://wiki.archlinux.org/title/Kernel_module)
- [Thread about disabling it](https://www.reddit.com/r/archlinux/comments/1124b9a/unable_to_disable_watchdog/)
- [`wdctl` man page](https://www.man7.org/linux/man-pages/man8/wdctl.8.html)
- [Linux kernel docs](https://www.kernel.org/doc/html/v6.8/admin-guide/lockup-watchdogs.html)
- [Post about hw one](https://aus.social/@Unixbigot/112962997893280387)
- [troubleshooting post](https://www.baeldung.com/linux/watchdog-message-explained)
- [Watchdog post](https://forum.proxmox.com/threads/watchdog-will-not-trigger-on-intel-system.152238/)
- [IPMI watchdog post](https://advantech-ncg.zendesk.com/hc/en-us/articles/360028285872-How-to-configure-the-BMC-watchdog-function-using-ipmitool)
- [Reddit comment](https://www.reddit.com/r/linux/comments/zcy0tn/comment/iyzrqai/)
- [Proxmox HA Wiki page](https://pve.proxmox.com/wiki/High_Availability_Cluster_4.x#IPMI_Watchdog_.28module_.22ipmi_watchdog.22.29)
- [Proxmox watchdog tutorial](https://it-notes.dragas.net/2018/09/16/proxmox-enable-and-use-watchdog-to-reboot-stuck-servers/)
