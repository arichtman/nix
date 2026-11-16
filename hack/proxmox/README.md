# Proxmox

- TODO: make a systemd unit and timer file for `vm-stall-recover.sh`

## Topton N100 (CW-AL-4L-V1.0 N100)

1. Download BIOS update and place on Ventoy USB.
1. Mash `F10` to enter BIOS, boot update.
   Enter `1` and it should update.
1. Reset and wait, it will beep and hang and reboot but eventually it should come good.
1. Set USB boot precendence above internal drive/s
1. Boot Proxmox installer and walk through
   Set static IP with netmask as same as router's DHCP netmask.
   Best I can tell this is required to send traffic _back_ to origin.
1. Highly recommended but optionally, trust your SSH keys.
   `curl https://github.com/arichtman.keys >> ~/.ssh/authorized_keys`
1. Optionally, add static DHCP lease to the router.
   If you do this, you can also optionally remove the fixed interface configuration.
   Edit `/etc/network/interfaces` and switch the virtual bridge network configuration from `manual` to `dhcp`.
1. Optionally, install trusted certificates.
   Instructions are on my blog.
1. Run some of [the proxmox helper scripts](https://tteck.github.io/Proxmox/)
   At least the post install one to fix sources.
   I also ran the microcode update, CPU scaling governor, and kernel cleanup (since I had been operating for a while).
1. Enable IOMMU. First, check GRUB/systemd `efibootmgr -v`.
   If GRUB, `sed -i -r -e 's/(GRUB_CMDLINE_LINUX_DEFAULT=")(.*)"/\1\2 intel_iommu=on"/' /etc/default/grub`
1. `echo 'vfio
    vfio_iommu_type1
    vfio_pci
    vfio_virqfd' >> /etc/modules`
1. Reboot to check config
1. Set BIOS settings:
   - Boot:
     - Disable beep
     - Enable fast boot
     - Enable network stack
   - Chipset:
     - PCH-IO:
       - Enable Wake on lan and BT
       - Enable TCO timer

1. Install Prometheus node exporter, `apt install prometheus-node-exporter`.
1. Install Avahi daemon to enable mDNS, `apt install avahi-daemon`.
1. Install grub package so actual grub binaries get updates, `apt install grub-efi-amd64`.
1. Optionally comment out the Cron job on reboot that sets it to power save.
1. Disable IPMI service since we don't have support, `systemctl disable openipmi`.
1. Optionally install the PVE Prometheus exporter.

If I check /etc/grub.d/000_ proxmox whatever it says `update-grub` isn't the way and to use `proxmox-boot-tool refresh`.
It also looks like there's a specific proxmox grub config file under `/etc/default/grub.d/proxmox-ve.cfg`.
I don't expect it _hurts_ much to have iommu on as a machine default, and we're not booting anything else...
Might tidy up the sed config command though.
Looking at the systemd we could probably do both without harm.
That one's also using the official proxmox command.

References:

- [Proxmox package repo docs](https://pve.proxmox.com/wiki/Package_Repositories)
- [Servethehome net passthru tutorial](https://www.servethehome.com/how-to-pass-through-pcie-nics-with-proxmox-ve-on-intel-and-amd/)
- [Reddit BIOS post](https://www.reddit.com/r/homelab/comments/1bzlicc/updating_bios_on_cwwk_n100_nas_motherboard/)
- [Actual BIOS download](https://pan.x86pi.cn/BIOS%E6%9B%B4%E6%96%B0/1.Intel%E8%BF%B7%E4%BD%A0%E4%B8%BB%E6%9C%BA%E7%B3%BB%E5%88%97BIOS/1.%E7%AC%AC12%E4%BB%A3AlderLake-U-P-N%E5%85%A8%E7%B3%BB%E5%88%97/1.%E7%AC%AC12%E4%BB%A3AlderLake-N%E5%85%88%E9%94%8B%E5%9B%9B%E7%BD%91N95-N100-N200-N305%E7%B3%BB%E5%88%97-V1-V2/1.%E7%AC%AC12%E4%BB%A3AlderLake-N%E5%85%88%E9%94%8B%E5%9B%9B%E7%BD%91%E7%B3%BB%E5%88%97-V1/AlderLake-N%E5%85%88%E9%94%8B%E5%9B%9B%E7%BD%91N100-N200-I3-N305-V1_%E5%87%BA%E5%8E%82%E9%BB%98%E8%AE%A4%E5%8E%9F%E5%A7%8B%E7%89%88/CW-AL-4L-V1.0(%E5%85%88%E9%94%8B%E5%9B%9B%E7%BD%91N95-N100-N200-I3-N305-V1%E5%87%BA%E5%8E%82%E9%BB%98%E8%AE%A4%E5%8E%9F%E5%A7%8B%E7%89%88%E6%9C%AC)23.04.28.iso)
- [Grub forum post](https://forum.proxmox.com/threads/update-installed-system-booted-in-efi-mode-but-grub-efi-amd64-meta-package-not-installed.137324/)
- [Arch wiki on CPU scaling](https://wiki.archlinux.org/title/CPU_frequency_scaling)
- [Proxmox performance tuning](https://sumguy.com/understanding-and-optimizing-performance-in-proxmox-ve/)
- [Proxmox CPU selection tutorial](https://www.yinfor.com/2023/06/how-i-choose-vm-cpu-type-in-proxmox-ve.html)
- [PVE Prometheus Exporter install](https://community.hetzner.com/tutorials/proxmox-prometheus-metrics)
- [PVE Prom Exporter TLS verify issue](https://github.com/prometheus-pve/prometheus-pve-exporter/issues/320)

#### Proxmox Disk Setup

We did run `mkfs -t ext4` but it didn't allow us to use the disk in the GUI.
So using GUI we wiped disk and initialized with GPT.

For the USB rust bucket we found the device name with `fdisk -l`.
~~Then we `mkfs -t ext4 /dev/sdb`, followed by a `mount /dev/sdb /media/backup`.~~
Never mind, same dance with the GUI, followed by heading to Node > Disks > Directory and creating one.

Use `blkid` to pull details and populate a line in `/etc/fstab` for auto remount of backup disk.
[Ref](https://www.baeldung.com/linux/automount-partitions-startup)

`/etc/fstab`:

```text
# <file system> <mount point> <type> <options> <dump> <pass>
/dev/pve/root / ext4 errors=remount-ro 0 1
UUID=C61A-7940 /boot/efi vfat defaults 0 1
/dev/pve/swap none swap sw 0 0
proc /proc proc defaults 0 0
UUID=b35130d3-6351-4010-87dd-6f2dac34cfba /mnt/pve/Backup ext4 defaults,nofail,x-systemd.device-timeout=5 0 2
```
