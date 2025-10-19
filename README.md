# Nix

**Stay frosty like Tony**

A home for my system configurations and home lab using Nix Flakes.

Be warned, I'm still learning and experimenting.

![As-is network and systems diagram](./assets/bedrock.drawio.svg "As-is networking diagram")

## Features and Todo

![Diagram of Earth's layers](./assets/layers.png "source: https://ucanr.edu/blogs/blogcore/postdetail.cfm?postnum=55747")

### Bedrock (Networking)

Features:

- ACME certificates for TLS on services
- Reverse proxy with mTLS protection to internal services
- Private CA TLS certificates for direct service access (k8s, OPNsense, Proxmox, access point)
- Wireguard VPN remote access
- Unencrypted client DNS trapped, filtered, and upgraded to DoT
- Malicious traffic dropped with dynamic list updates
- DDNS
- QEMU guest agent
- Prometheus metrics export
- Wake-on-LAN GUI
- Configuration backed up to two locations

Todo:

- Maybe [Tailscale OPNsense](https://tailscale.com/kb/1097/install-opnsense)
- Test local DNS from VPNs
- Find a DDNS provider that supports the generic update mechanism, not a proprietary API.
  Switch to Inadyne DDNS client for that?
- Host authoritative DNS server, maybe Hickory.
  See [ns-global](https://ns-global.zone/) for some resiliency.
- Review `net.inet.tcp.tso` for VM safety/perf
- Add dNAT port forwarding for Proxmox managment GUI from 443 to 8006
- Tune Wireguard
- Add IPsec
- Fix/add OpenVPN
  [ref](https://www.reddit.com/r/OPNsenseFirewall/comments/1adzr5y/openvpn_setup_instances_getting_ipv6_address_error/)
  [ref](https://forum.opnsense.org/index.php?topic=42672.0)
- Figure out why DNAT of DNS traffic to loopback doesn't work and has to be LAN IP address
- Figure out how to make the configuration work when the v6 prefix changes
- Add compatibility option/translation layer for IPv6->IPv4
- Remove IPv4
- Host an authoritative DNS
- See about getting my own AS and IPv6 prefix

### Substratum (Virtualization and Systems)

Features:

- iPXE/TFTP with Netboot for multi-option
- Automatic disk resize on NixOS VMs
- Mix of VMs and physical nodes
- Standardized configuration and configuration management of all nodes

Todo:

- Convert nodes to use ssh certificates for client authentication and server certificates instead of TOFU
- Swap my user to a lower privilege one on Proxmox and OPNsense
- See about more modern watchdog options - apparently this one is ancient 32 bit PCI
- Debug watchdog not stopping on control node reboot.
- Either stabilize or hardware watchdog Topton N100
- Work out watchdog on OPNsense/BSD
- Set up OpenAMT for out-of-band management.

### Subsoil (Foundational Services)

Features:

- Caddy reverse proxy
- Prometheus+Alertmanager+Grafana monitoring stack
- Garage S3 cluster
- Valheim server
- Nix binary cache
- Kanidm identity management

Todo:

- Advanced monitoring (Mimir, Tempo, Loki, Trickster, Victoria Metrics, etc)
- Add rules for k8s apiserver, maybe [mixins](https://github.com/kubernetes-monitoring/kubernetes-mixin/)
- Configure what can be for Otel
- Spire for node identity
- Stop Spire agent dying if stale join token
- Secrets (Vault/OpenBao?)
- Certificate authority? (step-ca?)
- More identity integration.
  Done:
  - Grafana
    To-do:
  - Proxmox (may be limited to authentication)
  - Step-CA [ref](https://smallstep.com/docs/step-ca/provisioners/#oauthoidc-single-sign-on)
  - OPNsense (LDAP only)
    Not possible:
  - Garage
- Switch routing to _dynamic_ subdomains.
- Add Uptime Kuma publicly
- Deploy external dead man's switch and route Alertmanager to it.
- Find a nice way to make foundational services upstream in Nginx config either nicer or subsume it.
- Look into different Nix store cache, maybe Attic or Harmonia

### Topsoil (Kubernetes)

Features:

- Custom, bare-metal deployment configuration
- Private CA certificates
- Single-stack IPv6 with native routing/no overlay
- Dynamic BGP peering of nodes with router/OPNsense
- CoreDNS inside cluster

Todo:

- External-DNS, Certificate-Manager, FluxCD
- Figure cluster bootstrapping out
- Do dynamically-delegated prefixes for node pod CIDRs.
  Honestly I'm not sure this is a value-add but it would be cool.
  See diagram below.
- Set up IPv6 public ingress and firewalling
- Enable [k8s native tracing](https://kubernetes.io/docs/concepts/cluster-administration/system-traces/)
- Enable `KubeletPSI` feature
- Use the kubernetes mkCert and mkKubeConfig functions [example](https://github.com/pl-misuw/nixos_config/blob/cce24d10374f91c2717f6bd6b3950ebad8e036d5/modules/k8s.nix#L11)
- Look into kubernetes managing itself with etc+cluster CAs in `/etc/kubernetes/pki`
- See about CSR auto-approval [project](https://github.com/postfinance/kubelet-csr-approver)
- Add WASM runtime
- Find some kind of dynamic PV/storage option.
  I'm thinking Longhorn.
  [post 1](https://akko.wtf/objects/79d8a9df-c1fe-4112-9d69-acc57977a0de)
  [post 2](https://akko.wtf/objects/1e198a8c-4850-4179-9f81-172a20af100b)
  Maybe OpenEBS.
- Play around with Timoni, Kluctl, etc
- Add tracing endpoint for Containerd, maybe monitor better
  [article](https://povilasv.me/how-to-monitor-containerd/)
  [prom docs](https://prometheus.io/docs/guides/opentelemetry/)
- "Package" an app using [generic Helm charts](https://github.com/bjw-s/helm-charts)
- Write a custom cloud provider using SSH and WoL.
- Adjust the custom cloud provider to use OpenAMT.
- Pull k8s module out into it's own flake/repo/overlay?
- Use sig-addonmanager to bootstrap a CD tool and a CNI
- Add SLOs to service monitoring [sloth](https://sloth.dev/)

![foolish mortals](./assets/native-k8s-ipv6.drawio.svg "What the fuck is this")

- [Cilium with OpnSense blog](https://dickingwithdocker.com/posts/using-bgp-to-integrate-cilium-with-opnsense/)
- [k8s setup with BGP and /64s](https://functional.cafe/@arianvp/112994181771306904)

### Organics (Applications and nice-to-haves)

- Look into `buildEnv` over `devShell`
- ~~Get a container image build with nix going~~
  [Jamey blog](https://jamey.thesharps.us/2021/02/02/docker-containers-nix/)
  [Amos's example](https://jamey.thesharps.us/2021/02/02/docker-containers-nix/)

## Implementation Notes

See also:

- [DNS](/dns.md)
- [CoreDNS](/coredns.md)
- [Cilium](/cilium.md)
- [MacOS](/mac.md)

### Bedrock

### Substratum

Pre-requisites:

- NixOS flashed to USB

#### HP EliteDesk 800 G3 Micro/Mini.

1. Mash F10/Esc to hit the bios (this was a thowback and a pain to do).
   Or just use `systemctl reboot --firmware-setup` ~ Future Ariel.
1. Update the BIOS
1. Load the settings from `HpSetup.txt` OR follow along the rest.
1. Configure the following
   - Ensure legacy boot is enabled.
   - I disabled secure boot and MS certificate in case
   - Turn off fast boot (might be optional)
   - Add boot delay 5 seconds (purely QoL)
   - Ensure USB takes priority over local disk
   - I disabled prompt on memory change so if I add RAM later I don't have to displace the system.
   - I disabled Intel's sgx or whatnot. Don't trust it after the RST debacle.
1. Save and reboot
1. Hit escape to select boot option of USB (esc maybe not required)
1. Follow the instructions to install NixOS
   - 23.05 (but higher is fine)
   - User _nixos_
   - Same password for `root`
   - Auto login (QoL but consult your threat model)
1. Use `nix-shell` to obtain Git and Helix
1. Clone this flake repo from github
1. Copy the machine-specific disk config from `/etc/nixos/hardware-configuration.nix`.
   Place it in the machine's `hardware-configuration.nix` in the flake repo.
   (This step may no longer be necessary)
1. Nix rebuild switch to the flake's config.
1. Confirm SSH remote access is working.
1. Reboot and enter bios.
   - Turn fast boot back on
   - Set boot delay to 0
   - Disable UEFI boot priority. If we need to boot from USB we'll reenter the BIOS.
1. Save BIOS changes and one last confirmation that the system boots and is remotable.
1. Move the machine to it's final home.
1. Remotely retrieve the hardware configuration and commit it to the flake repo.

#### Topton N100 (CW-AL-4L-V1.0 N100)

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

#### Re-IDing a Proxmox VM

I used this to shift OPNsense to 999 and any templates to >=1000.

1. Stop VM
1. Get storage group name `lvs -a`
1. Rename disk `lvrename prod vm-100-disk-0 vm-999-disk-0`
1. Enter `/etc/pve/nodes/proxmox/qemu-server`
1. Edit conf file to use renamed disk.
1. Move conf file to new id

- [Proxmox vmid change knowledge base article](https://bobcares.com/blog/change-vmid-proxmox/)

#### Virtual node disk resize

```bash
nix-shell -p cloud-utils
growpart /dev/sda 1
resize2fs /dev/sda1
```

#### Opnsense

##### VM Setup

1. Download iso and unpack
1. Move iso to `/var/lib/vz/template/iso`
1. Create VM with adjustments:
   I'm trying 2 cores now, utilization was low but we had spikes which I suspect were system stuff
   - Start at boot
   - SSD emulation, 48GiB
   - 1 socket+ 2 cores, NUMA enabled
   - 2048 MiB RAM
1. Use proxmox under datacenter to configure a backup schedule.
   The following should keep a rolling 4-weekly history.
   - Sunday 0100
   - Notify only on fail
   - Keep weekly 4
1. Boot machine and follow installer
1. Add PCIe ethernet controllers

##### Base OS Setup

1. Boot system and root login
1. Assign WAN and LAN interfaces to ethernet controllers
1. Check for updates either `opkg update` or maybe system > firmware
1. Add static DHCP leases for any machines using static IPs so Upbound will serve records for them
1. Install an intermediate cert and it's corrosponding bundle under system > trust
1. Switch to using the TLS certificate under System > Settings > Administration
1. Set both interfaces to delete protected and IPv6 SLAAC
1. Under System > General:
   - set hostname
   - set domanin
   - configure DNS servers
   - Disallow DNS override on WAN
1. Reporting > netflow set capture on
1. System > settings > cron
   - once daily to update the block lists
   - once weekly after the backup is taken (this ensures we can restore)

##### Tuning

- Follow [Ben Tasker's stuff](https://www.bentasker.co.uk/posts/blog/general/opnsense-pfsense-fttp-and-1gbps-pppoe.html)

Set tunable `kernel.ipc.maxsockbuf` to `33554432` (2 * 16777216 - the failing requested amount).
[Ref](https://github.com/opnsense/plugins/issues/627#issuecomment-420614278)

##### DNS Configuration

1. Configure Upbound DNS service
   - enable DNSSEC
   - enable DHCP lease registration
   - Disallow system nameservers in DoT and add records with blank domains+port 853
   - Enable blocklists
     - OIDS Ads
     - Steven Black
     - Hagezi Multi Pro++
   - Enable data capture

##### Firewall Configuration

1. Firewall
   - Add aliases for static boxes, localhost
   - Create a NAT port-forward:
     - LAN interface
     - IPv4+6
     - TCP+UDP
     - Invert
     - Destination LAN net
     - from dns to dns
     - Redirect target Localhost:53
1. Test
   - DNS redirection:
     - Unbound host override bing.com to something
     - Check this returns the override `dig +trace @4.4.4.4 bing.com`
   - Ad blocking https://d3ward.github.io/toolz/adblock.html
1. Block bad IPs
   1. Add aliases for IP lists (see references)
   1. Add firewall rules:
      Either floating destination FireHOL level 3 + Spamhaus OR
      WAN outbound FireHOL Level 1 + WAN inbound all bad IPs

- [Unbound DoT tutorial](https://homenetworkguy.com/how-to/configure-dns-over-tls-unbound-opnsense/)
- [DNS tutorial](https://homenetworkguy.com/how-to/redirect-all-dns-requests-to-local-dns-resolver/)
- [OPNsense forum thread](https://forum.opnsense.org/index.php?topic=17596.0)
- [Blocking blog post](https://www.allthingstech.ch/using-opnsense-and-ip-blocklists-to-block-malicious-traffic)
- [Fedi posts about it](https://chaos.social/@JeGr/114406585868980716)
  [alt server](https://eigenmagic.net/deck/@JeGr@chaos.social/114406575249856820)
  [Spamhaus](https://docs.opnsense.org/manual/how-tos/drop.html)

##### OpenVPN

Follow one of the 6000 tutorials AKA yes, I forgot to document it.

- [OpenVPN setup guide](https://sysadmin102.com/2024/03/opnsense-openvpn-instance-remote-access-ssl-tls-user-auth/())

##### WireGuard

Follow tutorial AKA forgot to document it.
See also `wg0.conf` in this repo.

##### Alacritty terminal

`/usr/local/etc/rc.syshook.d/update/99-alacritty-terminal`:

```shell
#!/bin/sh
# Configures terminal for Alacritty

curl -sSL https://raw.githubusercontent.com/alacritty/alacritty/master/extra/alacritty.info -o alacritty.info
infotocap alacritty.info >> /usr/share/misc/termcap
cap_mkdb /usr/share/misc/termcap
rm alacritty.info
```

- [Blog](https://www.mcarlin.com/blogs/alacritty-freebsd-termcap/)
- [Hooks docs](https://docs.opnsense.org/development/backend/autorun.html)

##### Nginx for Kanidm

Nginx configuration on OPNsense requires modification for Kanidm Oauth to work!

1. Inspect the generated configuration file, either via SSH or Web console
1. Locate the `server` block for the Kanidm HTTP server
1. There should be a line like `include $UUID_post/*.conf`, note the directory name.
1. Create such a directory in `/usr/local/etc/nginx`, and add a `.conf` file with the following:
   `proxy_pass_header X-KANIDM-OPID;`
1. Restart the nginx service

##### Plugins

- NextCloud backup, configure with an app key.
- Git backup. Create an uninitialized repository and provide API key and HTTPS URL.
- Prometheus exporter for monitoring.
- DynamicDNS client, configure with AWS Access Key.
- tftp plugin (unmaintained but workable)
  [src](https://github.com/opnsense/plugins/tree/master/ftp/tftp).
  Make directory `/usr/local/tftp` and download `netboot.xyz.kpxe`.
  I also downloaded `netboot.xyz.efi` for good measure.
  Enable TFTP and set listening IP to `0.0.0.0`.
  This defaulted to `127.0.0.1` which may have worked but I didn't test.
- ACME client [tutorial](https://forum.opnsense.org/index.php?topic=24778.0)
- Install `os-wol` to wake on lan.
  Add all physical machines to the list of known, you can use ISC DHCP leases to find all the MACs in one place.
- Optionally: themes (rebellion)

Notes:

I will revisit the resources supplied after running the box for a bit.

CPU seems fine, spikey with what I think are Python runtime startups from the control layer.
RAM looks consistently under about 1Gb so I'll trim that back from the
[recommended minimum](https://docs.opnsense.org/manual/hardware.html) 2Gb.
We're doing pretty well on space too but I'm less short on that.

References:

- [Reddit performance comment](https://www.reddit.com/r/OPNsenseFirewall/comments/guo2iz/comment/fskpk76)

#### Disaster Recovery / Restoring from Backup

1. Access Proxmox [directly](https://proxmox.internal:8006)
1. Visit Backup storage and confirm thre is an intact and appropriate snapshot image to restore.
1. Disable VM protection and delete it.
1. Select backup image and restore to VM ID `999`.
   Enable start on boot and disable unique feature.

### Virtualized NixOS Node Bootstrap

1. Use GUI installer to deploy, the CLI one's a pain, 12GiB storage minimum, 4 cores/8GiB ram (min 4+ GiB).
   We'll scale it down later, it bombs completely without plenty of RAM.
1. Thing's a pain to bootstrap and the web console is limited
   Sudo edit `/etc/nixos/configuration.nix`
   - Enable the openssh service
   - `security.sudo.wheelNeedsPassword = false`
   - Disable OSprober by removing the line
   - Set disk source to `/dev/sda`
   - I'm not sure those last 2 make much of a difference once the machine is under flake control
1. Rebuild
1. Bounce the machine so it releases using the new hostname
1. Then pull down some keys to get in, it should have already DHCP'd over the bridge network.
   `mkdir ~~/.ssh && curl https://github.com/arichtman.keys -o ~/.ssh/authorized_keys && chmod 600 ~~/.ssh/authorized_keys`
1. Upgrade the system
   `sudo nixos-rebuild switch --upgrade --upgrade-all`
1. Reboot to test
1. Clear history
   `sudo nix-rebuild list-generations`
   `sudo rm /nix/var/nix/profiles/system-#-profile`
   `sudo nix-collect-garbage --delete-old`
1. Adjust hardware down to 1/2GiB.
1. Make template

- [Nixos VM tutorial](https://mattwidmann.net/notes/running-nixos-in-a-vm/)

### Subsoil

#### Trust chain setup

Arguably this mingles with substratum, as PKI/trust/TLS is required or very desirable for VPN/HTTPS etc.
SPIFFE/SPIRE will address this somewhat.

1. Create root CA
   `xkcdpass --delimiter - --numwords 4 > root-ca.pass`
   `step certificate create "ariel@richtman.au" ./root-ca.pem ./root-ca-key.pem --profile root-ca --password-file ./root-ca.pass`
1. Distribute the intermediate certificates and keys
1. Secure the root CA, it's a bit hidden but Bitwarden _does_ take attachments.
1. Publish the root CA, with my current setup this meant uploading it to s3.
1. Update the sha256 for the root certificate `fetchUrl` call

- [Smallstep documentation](https://smallstep.com/docs/step-cli/basic-crypto-operations/index.html)
- [Certificate creation/authorization tutorial](https://yuminlee2.medium.com/kubernetes-generate-certificates-for-normal-users-using-certificates-api-7ba71170aa52)

#### Garage setup

```bash
garage layout assign --zone garage.services.richtman.au --capacity 128GB $(garage node id 2>/dev/null)
garage layout apply --version 1
```

#### Kanidm setup

```bash
export KANIDM_URL=https://id.richtman.au
export GRAFANA_FQDN=grafana.services.richtman.au
kanidm system oauth2 create grafana $GRAFANA_FQDN https://$GRAFANA_FQDN
kanidm system oauth2 set-landing-url grafana "https://${GRAFANA_FQDN}/login/generic_oauth"

kanidm group create 'grafana_superadmins'
kanidm group create 'grafana_admins'
kanidm group create 'grafana_editors'
kanidm group create 'grafana_users'

kanidm system oauth2 update-scope-map grafana grafana_users email openid profile groups
kanidm system oauth2 enable-pkce grafana

kanidm system oauth2 update-claim-map-join 'grafana' 'grafana_role' array
kanidm system oauth2 update-claim-map 'grafana' 'grafana_role' 'grafana_superadmins' 'GrafanaAdmin'
kanidm system oauth2 update-claim-map 'grafana' 'grafana_role' 'grafana_admins' 'Admin'
kanidm system oauth2 update-claim-map 'grafana' 'grafana_role' 'grafana_editors' 'Editor'

# Note: I'm not sure I need *all* of these
kanidm group add-members grafana_superadmins arichtman
kanidm group add-members grafana_admins arichtman
kanidm group add-members grafana_editors arichtman
kanidm group add-members grafana_users arichtman

kanidm system oauth2 get grafana
kanidm system oauth2 show-basic-secret grafana
```

Grafana side: [Official docs examples](https://kanidm.github.io/kanidm/stable/integrations/oauth2/examples.html#grafana)

#### Topsoil

- [Kubernetes the hard way](https://github.com/kelseyhightower/kubernetes-the-hard-way)

##### Cluster access bootstrap

```bash
# Create a client certificate with admin
step certificate create cluster-admin cluster-admin.pem cluster-admin-key.pem \
  --ca ca.pem --ca-key ca-key.pem --insecure --no-password --template granular-dn-leaf.tpl --set-file dn-defaults.json --not-after 8760h \
  --set organization=system:masters
# Construct the kubeconfig file
# Here we're embedding certificates to avoid breaking stuff if we move or remove cert files
kubectl config set-cluster home --server https://fat-controller.systems.richtman.au:6443 --certificate-authority ca.pem --embed-certs=true
kubectl config set-credentials home-admin --client-certificate cluster-admin.pem --client-key cluster-admin-key.pem --embed-certs=true
kubectl config set-context --user home-admin --cluster home home-admin
```

#### Cluster access (normal)

1. Create private key `openssl genpkey -out klient-key.pem -algorithm ed25519`
1. Create CSR `openssl req -new -config klient.csr.conf -key klient-key.pem -out klient.csr`
1. `export KLIENT_CSR=$(base64 klient.csr | tr -d "\n")`
1. Submit the CSR to the cluster `envsubst -i klient-csr.yaml | kubectly apply -f -`
1. Approve the request `kubectl certificate user approve`

#### Cluster node roles

For security reasons, it's not possible for nodes to self-select roles.
We can label our nodes using `label.sh`.

hmmm, deleting the nodes (reasonably) removes labels.
...and since they can't self-identify, we have to relabel every time.
I expect taints would work the same way, so we couldn't use a daemonset or spread topology with labeling privileges since it wouldn't know what to label the node.
Unless... we deploy it with a configMap? That's kinda lame.
I suppose all the nodes that need this are dynamic, ergo ephemeral and workers, so we could make something like that.
Heck, a static pod would work fine for this and be simple as.
But then it'd be a pod, which is a continuous workload, which we really don't need.
A job would suit better, but then it's like, why even run this on the nodes themselves?
Have the node self-delete (it'll self-register again anyway), and have the admin box worry about admin like labelling.
I wonder if there's any better way security-wise to have nodes be trusted with certain labels.
Already they need apiServer-trusted client certificates, it'd be cool if the metadata on those could determine labels.

There is a way to tell the Kubelet to register with labels but it's limited to a specific group.
I doubt the Kubelet has an option to open that up and since we're getting denied even starting the binary it's probably not settable on the APIserver.

#### Node CSRs piling up

`kubectl get csr --no-headers -o jsonpath='{.items[*].metadata.name}' | xargs -r kubectl certificate approve`

- [GitHub comment](https://github.com/dyrnq/kubeadm-vagrant/issues/4#issuecomment-917590114)

#### Notes

Checking builds manually: `nix build .#nixosConfigurations.fat-controller.config.system.build.toplevel`
Minimal install ~3.2 gigs
Lab-node with master node about 3.2 gb also, so will want more headroom.

Add to nomicon

- fakesha256
- nix-prefetch-url > hash.txt

## Android phone setup

Using tasker

```yaml
Profile: AutoPrivateDNS
         State: Wifi Connected [ SSID:sugar_monster_house MAC:* IP:* Active:Any ]
     Enter: Anon
         A1: Custom Setting [ Type:Global Name:private_dns_mode Value:off Use Root:Off Read Setting To: ]
     Exit: Anon
         A1: Custom Setting [ Type:Global Name:private_dns_mode Value:hostname Use Root:Off Read Setting To: ]
```

Secure setting `accessibility_display_daltonizer_enabled` to `0` or `1` for color toggle.

`nix shell nixpkgs#android-tools -c adb shell pm grant net.dinglisch.android.taskerm android.permission.WRITE_SECURE_SETTINGS`

References:

- [StackExchange](https://android.stackexchange.com/a/239471)
- [AdGuard instructions for secret settings](https://adguard.com/kb/adguard-for-android/solving-problems/firefox-certificates/)
- [HN post](https://news.ycombinator.com/item?id=40465686)

## Desktops

### Mac

Trust chain system install:
`sudo security add-trusted-cert -r trustRoot -k /Library/Keychains/System.keychain -d ~/Downloads/root-ca.pem`

#### Old MBP setup

OPNsense/openssl's ciphers are too new, to install client certificate you may need to pkcs12 bundle legacy.
`openssl pkcs12 -export -legacy -out Certificate.p12 -in certificate.pem -inkey key.pem`

- [StackOverflow post](https://stackoverflow.com/a/74792849)

#### MBP M2 setup

1. Update everything `softwareupdate -ia`
1. Optionally install rosetta `softwareupdate --install-rosetta --agree-to-license`
   I didn't explicitly install it but it's on there somehow now.
   There was some mention that it auto-installs if you try running x86_64 binaries.
1. Determinant systems install nix
1. Until this is resolved https://github.com/LnL7/nix-darwin/issues/149
   `sudo mv /etc/nix/nix.conf /etc/nix/.nix-darwin.bkp.nix.conf`
1. Nix-Darwin build and run installer

```
nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A installer
./result/bin/darwin-installer

edit default configuration.nix? n
# Accept the option to manage nix-darwin using nix-channel or else it bombs
manage using channels? y
add to bashrc y
add to zshrc? y
create /run? y
# a nix-channel call will now fail
```

Bootstrapping:

1. do the xcode-install method
1. Build manually once `nix build github:arichtman/nix#darwinConfigurations.macbook-pro-work.system`
1. Switch manually once `./result/sw/bin/darwin-rebuild switch --flake .#macbook-pro-work`
1. If bootstrapped, build according to flake `./result/sw/bin/darwin-rebuild switch --flake github:arichtman/nix`

To do: look into [Nix VMs on Mac](https://paretosecurity.com/blog/being-a-happy-nixer-on-a-mac/)

### Universal Blue

some _very_ wip notes about the desktop.

- Installer with nVidia drivers worked ok in simplified mode
- Despite the claims of signing automation for secure boot it still needs to be disabled, 'less you like 800x600.
- Bluetooth pair the speaker though you may have to change the codec in settings > sound
- I ran `bluetoothctl trust $MAC` to try and start off autoconnect
- I fiddled about in display settings to get orientation of monitors correct
- `sudo visudo` and swap the commented lines for wheel to enable `NOPASSWD`.
- Suppress/fix warnings about running Nix commands as myself:
  Added `trusted-users = @wheel` to `/etc/nix/nix.custom.conf` (DetSys thing not to use `/etc/nix/nix.conf`).
  Note: might be able to specify this at install time...
- Enable composefs transient root, then install DetSys Nix (for SELinux support).
  `/etc/ostree/prepare-root.conf`:

  ```toml
  [composefs]
  enabled = yes
  [root]
  transient = true
  ```

  Then `sudo rpm-ostree initramfs-etc --reboot --track=/etc/ostree/prepare-root.conf`.
  [Reference](https://github.com/coreos/rpm-ostree/issues/337#issuecomment-2856321727)
- Used `nix develop` to bootstrap
- `home-manager switch --flake . -b backup`
- Installed my root certificate
  `sudo curl https://www.richtman.au/root-ca.pem -o /etc/pki/ca-trust/source/anchors/root-ca.pem`
  `sudo update-ca-trust`
- Set my shell to Zsh `sudo usermod --shell $(which zsh) arichtman`.
  Note: not sure how this is going, obvs that path isn't in `/etc/shells`, but I can't see any `bash-default-shell` in `rpm-ostree`.
  Reboot and see if it applies on login.
- Install system level layers with zsh and alacritty.
  `sudo rpm-ostree install -y --idempotent zsh alacritty`
- Fix failure to wake from sleep.
  `/usr/lib/systemd/system/service.d/50-keep-warm.conf`:

  ```toml
  # Disable freezing of user sessions to work around kernel bugs.
  # See https://bugzilla.redhat.com/show_bug.cgi?id=2321268
  [Service]
  Environment=SYSTEMD_SLEEP_FREEZE_USER_SESSIONS=0
  ```

  [Reference](https://gitlab.gnome.org/GNOME/gnome-shell/-/issues/8292#note_2445334)
- Enabled WoL [tutorial](https://www.maketecheasier.com/enable-wake-on-lan-ubuntu/)

### Desktop Todo

- Set resolved's upstream DNS from DHCPv4, figure out what to do about v6 dynamic DNS server.
- Get CLI clipboard access
  [post](https://fosstodon.org/@ferki/112868797150769449)
- Learn about universal blue/ostree and decide if I want to keep this
- look into errors running `tracker-miner-fs-3.service`
- Work out how to uninstall `nano-default-editor` `rpm-ostree override remove`
- Fix failing Alacritty launchpad launch
- Fix failing `systemd-remount-fs.service`

## Nix References

- [Opinionated flake structure](https://github.com/snowfallorg/lib)
- [Home-manager configuration options](https://nix-community.github.io/home-manager/options.html)
- [Misterio77's starter configs](https://github.com/Misterio77/nix-starter-configs)
- Just generally sucking at it, spelunking `nixpkgs` and `NixOS-WSL` source Nix files
- [Jake Hamilton videos](https://www.youtube.com/@jakehamiltondev)
- [Nebucatnetzer's config](https://git.2li.ch/Nebucatnetzer/nixos/)
- [Post about inline nix use helm](https://hdev.im/@farcaller/113018001043836518)
