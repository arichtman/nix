# Watchdog

## Proxmox

### BIOS

BIOS has an option to enable TCO but no timer settings.
This is an Intel board so kernel module `iTCO_wdt` is the correct one.

### Other Watchdogs

`dmesg` says NMI watchdog is enabled, but HA wiki says disable that.

`/etc/default/grub`:

```
GRUB_CMDLINE_LINUX_DEFAULT="quiet nmi_watchdog=0"
```

Follow this by `update-grub` and a reboot.
We can confirm with `dmesg | grep nmi`.

I can still see `wdctl /dev/watchdog0` showing softdog though.
Maybe NMI is the CPU watchdog.

### Kernel Support

`modinfo iTCO_wdt` looks like it's in the kernel, which means no patching or recompiling.

This is supposed to select the module to use.

`/etc/default/pve-ha-manager`:

```
WATCHDOG_MODULE=iTCO_wdt
```

I've also set these trying:

`/etc/modules-load.d/watchdog.conf`:

```
iTCO_wdt
wdat_wdt # Not sure if we need this
```

This should provide configuration to the kernel module.

`/etc/modprobe.d/watchdog.conf`:

```
options iTCO_wdt nowayout=0 heartbeat=30
#options wdat_wdt timeout=30
#options softdog nowayout=1
```

I've added `/etc/modules` to contain `iTCO-wdt heartbeat=60`.

Watchdog modules are blacklisted by default due to the footgunny nature of a boot loop.

`modprobe -c | grep iTCO_wdt` shows 2 x blacklist entries and some options.

`systemd-analyze cat-config modprobe.d` and `modprobe -c` shows them blacklisted...

### Service Configuration

`wdctl` _should_ be showing status but `/dev/watchdog` is missing.
There's a `watchdog-mux.service` but it's inactive(dead) and nothing in journalctl.
Enabling/starting it yields a device or resource busy.
And there *is* a special character file at `/dev/watchdog`.
`lsof | grep /dev/watchdog` yields only `systemd` holding `/dev/watchdog0`.
This should be pointing systemd at `/dev/watchdog`.
Perhaps systemd is clashing with watchdog-mux.

`/etc/systemd/system.conf.d/10-watchdog.conf`:

```
[Manager]
RuntimeWatchdogSec=60
WatchdogDevice=/dev/watchdog
#RuntimeWatchdogPreSec=off
#RuntimeWatchdogPreGovernor=
#RebootWatchdogSec=10min
#KExecWatchdogSec=off
```

Timeout settings weren't coming successfully from adding module parameters to either `modprobe.d` or during `modprobe` calls.
Editing the `system.conf.d` file and running `systemctl daemon-reexec` did take the changes.

Removing the systemd watchdog configuration allowed watchdog-mux to start okay.
`wdctl` defaults to `watchdog0`, softdog. `wdctl /dev/watchdog` says no such file, though `stat` reports it's there.

Perhaps the driver isn't working right/configured, which is bubbling up in file semantics as not found.

## VMs

1. Add `watchdog: model=i6300esb,action=reset` to the conf file in `/etc/pve/qemu-server/`.
1. Enable NixOS `services.watchdogd`.
1. Stop and start the VM.

## Leftover notes

```
modprobe wdat_wdt timeout=30
modinfo wdat_wdt
modprobe --show-depends wdat_wdt
```

## IPMI

In case I need it...

`ipmitool` can't locate and IPMI devices (`/dev/ipmi*`) because that's for other manufacturers.

```
modprobe ipmi_devintf
modprobe ipmi_msghandler
# This fails cause no device
modprobe ipmi_si
```

> If you're using systemd then you probably want to set RuntimeWatchdogSec= in /etc/systemd/system.conf and let the init process take care of poking the watchdog.


- [Arch wiki about watchdogs](https://wiki.archlinux.org/title/Improving_performance#Watchdogs)
- [Arch wiki kernel modules](https://wiki.archlinux.org/title/Kernel_module)
- [Arch wiki kernel parameters](https://wiki.archlinux.org/title/Kernel_parameters)
- [Thread about disabling it](https://www.reddit.com/r/archlinux/comments/1124b9a/unable_to_disable_watchdog/)
- [`wdctl` man page](https://www.man7.org/linux/man-pages/man8/wdctl.8.html)
- [Linux kernel docs](https://www.kernel.org/doc/html/v6.8/admin-guide/lockup-watchdogs.html)
- [Linux kernel watchdog parameters](https://www.kernel.org/doc/html/latest/watchdog/watchdog-parameters.html)
- [Post about hw one](https://aus.social/@Unixbigot/112962997893280387)
- [troubleshooting post](https://www.baeldung.com/linux/watchdog-message-explained)
- [Watchdog post](https://forum.proxmox.com/threads/watchdog-will-not-trigger-on-intel-system.152238/)
- [IPMI watchdog post](https://advantech-ncg.zendesk.com/hc/en-us/articles/360028285872-How-to-configure-the-BMC-watchdog-function-using-ipmitool)
- [Reddit comment](https://www.reddit.com/r/linux/comments/zcy0tn/comment/iyzrqai/)
- [Proxmox HA Wiki page](https://pve.proxmox.com/wiki/High_Availability_Cluster_4.x#IPMI_Watchdog_.28module_.22ipmi_watchdog.22.29)
- [Proxmox watchdog tutorial](https://it-notes.dragas.net/2018/09/16/proxmox-enable-and-use-watchdog-to-reboot-stuck-servers/)
- [Versa networks support article](https://support.versa-networks.com/support/solutions/articles/23000025433-how-to-enable-cpu-itco-watchdog)
- [SO about iTCO_wdt](https://stackoverflow.com/questions/78746159/how-to-use-intel-tco-watchdog-with-itco-wdt)
- [Systemd-system.conf](https://www.man7.org/linux/man-pages/man5/systemd-system.conf.5.html)
- [Random Ubuntu 12 tutorial](https://github.com/miniwark/miniwark-howtos/blob/master/setup_the_hardware_watchdog_timer_on-ubuntu_12.04.md)
