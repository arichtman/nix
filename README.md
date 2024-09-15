# Nix

**Stay frosty like Tony**

A home for my system configurations using Nix Flakes
Be warned, I'm still learning and experimenting.

~~Nothing here should be construed as a model of good work!... yet.~~
Y'know, I'm starting to feel pretty good about this.

## Features and Todo

![Diagram of Earth's layers](./assets/layers.png "Diagram of Earth's layers")

<!-- source: https://ucanr.edu/blogs/blogcore/postdetail.cfm?postnum=55747&sharing=yes -->

### Bedrock (Networking)

- Maybe [Tailscale OPNsense](https://tailscale.com/kb/1097/install-opnsense)
- Enable mDNS bridging to VPN interfaces
- Enable mDNS responses from OPNsense box
- Set resolved's upstream DNS from DHCPv4, figure out what to do about v6 dynamic DNS server.
- Look into roles anywhere for DDNS
  [docs](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_common-scenarios_non-aws.html)
- Find a DDNS provider that supports the generic update mechanism, not proprietary API (obsoletes IAM roles anywhere).
  Switch to Inadyne DDNS client for that.
- Configure secondary router to [repeat mDNS](https://www.snbforums.com/threads/mdns-repeater-with-guest-network-vlan.86503/),
  [other thread](https://www.snbforums.com/threads/help-with-avahi-mdns-redirector-please.86537/).
- Configure Proxmox IPv6 address. [docs](https://wiki.debian.org/NetworkConfiguration)
- Set up valid TLS for secondary router.
  I have successfully uploaded a valid TLS leaf certificate but it doesn't seem to be serving it.
- ~~Enable IPv6 DNS server for Wireguard on MacOS.
  [StackExchange post](https://apple.stackexchange.com/questions/309430/ipv6-dns-resolution-on-macos-high-sierra)~~
- ~~Configure downstream router to trap DNS and forward to Unbound.~~
- ~~Properly set up the access point as a downstream router (with PD)~~
  Done! Sweaty, slightly stressful afternoon but worth it.
- ~~Set up VPN in OPNsense~~
  WG and OpenVPN working.
  Might do IPsec too or further tuning.
- ~~Think about DoH https://homenetworkguy.com/how-to/configure-dns-over-https-dnscrypt-proxy-opnsense/~~
   Implemented along with reverse-proxy trapping.
- ~~Set up valid TLS for OPNsense and Proxmox~~

### Substratum (Virtualization and Systems)

- Convert nodes to use ssh certificates for client authentication and server certificates instead of TOFU
- Swap my user to a lower privilege one on Proxmox and OPNsense
- See about more modern watchdog options - apparently this one is ancient 32 bit PCI
  [post about hw one](https://aus.social/@Unixbigot/112962997893280387)
- Set up OpenAMT for out-of-band management.
- Work out watchdog on Opnsense BSD
- Configure Topton N100 watchdog.
  BIOS setting located but microcode update seems to have stabilized the system.
- ~~Set up PXE booting off of OPNsense
  [gist](https://gist.github.com/azhang/d8304d8dd4b4c165b67ab57ae7e1ede0)~~
  IPv4 PXE working.
- ~~Set up iPXE or something so multiple options.
  [iPXE](https://ipxe.org/)
  [netboot](https://netboot.xyz/)~~
  iPXE working.
- ~~See about nixos on-boot auto disk resize (and add to template!)~~
  Virtual nodes auto-resizing, physical nodes no point.
- ~~`system.autoUpgrade.enable` make it Wednesday morning, after our scheduled CI flake updates~~
  Without rollback and strong CI this feels risky, I might do this manually for a while until I'm confident

### Subsoil (Foundational Services)

- Determine "foundational services" (and set up)
  - Prometheus
  - Grafana
  - NixOS store cache (Attic?)
  - Secrets (Vault/OpenBao?)
  - Object storage (Minio?)
  - Certificate authority? (step-ca?)
  - Identity (Authentik/Kanidm/Guacamole/Gluu)
- Look into where makes sense to bootstrap secrets/vault/trust
- Deploy reverse proxy with ACME/LetsEncrypt.
  Configure secondary reverse proxy to services.
- Enable DNS-01 challenge for reverse proxy so internal domain SANs can be added.
- Enable mTLS to protect some routes. [Caddy docs](https://caddyserver.com/docs/caddyfile/directives/tls)
- Switch routing to dynamic subdomains.
- Add Uptime Kuma publicly
- Apply WAF protection.
- Deploy CrowdSec.

### Topsoil (Kubernetes)

- Write my own k8s module (in progress)
- Pull k8s module out into it's own flake/repo/overlay.
- Swap kubernetes to IPv6
- Set up IPv6 ingress and firewalling
- BGP peer cluster to router?
  See crazy diagram for IPv6
- Use the kubernetes mkCert and mkKubeConfig functions [example](https://github.com/pl-misuw/nixos_config/blob/cce24d10374f91c2717f6bd6b3950ebad8e036d5/modules/k8s.nix#L11)
- Look into kubernetes managing itself with etc+cluster CAs in `/etc/kubernetes/pki`
- See about CSR auto-approval [project](https://github.com/postfinance/kubelet-csr-approver)
- Work out graceful node shutdown to remove them from the API server
- Find some kind of dynamic PV/storage option
  [post 1](https://akko.wtf/objects/79d8a9df-c1fe-4112-9d69-acc57977a0de)
  [post 2](https://akko.wtf/objects/1e198a8c-4850-4179-9f81-172a20af100b)
- Play around with Timoni, Kluctl, etc
- "Package" an app using [generic Helm charts](https://github.com/bjw-s/helm-charts)
- Write a custom cloud provider using SSH and WoL.
- Adjust the custom cloud provider to use OpenAMT.
- ~~Work out what's to replace addon-manager~~
  It's sig-addonmanager, I think.
  That can be a static pod on the control plane and in turn bootstrap FluxCD/Cilium.
- ~~Look into reducing apiserver kubelet permissions to `kubeadm:cluster-admins`~~
  Node authorization enabled so clients with signed `O=cluster:nodes:$NAME` are working.
- ~~Pull common kubernetes config out into another module~~
- ~~Possibly rewrite the Kubernetes module(s)~~
- ~~Fix addonManager not finding anything to apply~~

![foolish mortals](./assets/native-k8s-ipv6.drawio.svg "What the fuck is this")

- [Cilium with OpnSense blog](https://dickingwithdocker.com/posts/using-bgp-to-integrate-cilium-with-opnsense/)
- [k8s setup with BGP and /64s](https://functional.cafe/@arianvp/112994181771306904)

### Organics (Applications and nice-to-haves)

- Look into `buildEnv` over `devShell`
- ~~Get a container image build with nix going~~
  [Jamey blog](https://jamey.thesharps.us/2021/02/02/docker-containers-nix/)
  [Amos's example](https://jamey.thesharps.us/2021/02/02/docker-containers-nix/)

## Implementation Notes

### Bedrock

![Annoyingly complicated networking](./assets/bedrock.drawio.svg "As-is networking diagram")

### Substratum

Pre-requisites:

- NixOS flashed to USB

### HP EliteDesk 800 G3 Micro/Mini.

1. Mash F10 to hit the bios (this was a thowback and a pain to do).
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

### Topton N100 (CW-AL-4L-V1.0 N100)

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
- [Watchdog post](https://forum.proxmox.com/threads/watchdog-will-not-trigger-on-intel-system.152238/)
- [Grub forum post](https://forum.proxmox.com/threads/update-installed-system-booted-in-efi-mode-but-grub-efi-amd64-meta-package-not-installed.137324/)
- [Arch wiki on CPU scaling](https://wiki.archlinux.org/title/CPU_frequency_scaling)
- [Proxmox performance tuning](https://sumguy.com/understanding-and-optimizing-performance-in-proxmox-ve/)

## Substratum

- [Proxmox CPU selection tutorial](https://www.yinfor.com/2023/06/how-i-choose-vm-cpu-type-in-proxmox-ve.html)

### Proxmox Disk Setup

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

### Re-IDing a Proxmox VM

I used this to shift OPNsense to 999 and any templates to >=1000.
1. Stop VM
1. Get storage group name `lvs -a`
1. Rename disk `lvrename prod vm-100-disk-0 vm-999-disk-0`
1. Enter `/etc/pve/nodes/proxmox/qemu-server`
1. Edit conf file to use renamed disk.
1. Move conf file to new id

- [Proxmox vmid change knowledge base article](https://bobcares.com/blog/change-vmid-proxmox/)

### Adding watchdog to a proxmox VM

1. Add `watchdog: model=i6300esb,action=reset` to the conf file in `/etc/pve/qemu-server/`.
1. Stop and start the VM.

- [Proxmox watchdog tutorial](https://it-notes.dragas.net/2018/09/16/proxmox-enable-and-use-watchdog-to-reboot-stuck-servers/)

### Virtual node disk resize

```bash
nix-shell -p cloud-utils
growpart /dev/sda 1
resize2fs /dev/sda1
```

### Opnsense

#### VM Setup

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

#### Base OS Setup

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

#### DNS Configuration

1. Configure Upbound DNS service
   - enable DNSSEC
   - enable DHCP lease registration
   - Disallow system nameservers in DoT and add records with blank domains+port 853
   - Enable blocklist and use OISD Ads only (to be experimented with)
   - Enable data capture

#### Firewall Configuration

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

- [Unbound DoT tutorial](https://homenetworkguy.com/how-to/configure-dns-over-tls-unbound-opnsense/)
- [DNS tutorial](https://homenetworkguy.com/how-to/redirect-all-dns-requests-to-local-dns-resolver/)

#### OpenVPN

Follow one of the 6000 tutorials AKA yes, I forgot to document it.

- [OpenVPN setup guide](https://sysadmin102.com/2024/03/opnsense-openvpn-instance-remote-access-ssl-tls-user-auth/())

#### WireGuard

Follow tutorial AKA forgot to document it.
See also `wg0.conf` in this repo.

#### Plugins

- NextCloud backup, configure with an app key.
- FRR BGP, BGP run `sysctl kern.ipc.maxsockbuf=16777216` as plugin post-install message suggests.
  (Not immediately in use, for Cillium later)
- Prometheus exporter.
  (Not immediately in use, for foundatinoal monitoring later)
- DynamicDNS client, configure with AWS Access Key.
- AMD microcode updates (unsure how wise this is given hypervisor is Intel)
  OPNsense already had this set up when I installed it but check post-install instructions.
- tftp plugin (unmaintained but workable)
  [src](https://github.com/opnsense/plugins/tree/master/ftp/tftp).
  Make directory `/usr/local/tftp` and download `netboot.xyz.kpxe`.
  I also downloaded `netboot.xyz.efi` for good measure.
  Enable TFTP and set listening IP to `0.0.0.0`.
  This defaulted to `127.0.0.1` which may have worked but I didn't test.
- ACME client [tutorial](https://forum.opnsense.org/index.php?topic=24778.0)
- optionally: themes

Notes:

I will revisit the resources supplied after running the box for a bit.

CPU seems fine, spikey with what I think are Python runtime startups from the control layer.
RAM looks consistently under about 1Gb so I'll trim that back from the
[recommended minimum](https://docs.opnsense.org/manual/hardware.html) 2Gb.
We're doing pretty well on space too but I'm less short on that.

References:

- [Reddit performance comment](https://www.reddit.com/r/OPNsenseFirewall/comments/guo2iz/comment/fskpk76)

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

## Subsoil

## Trust chain setup

Arguably this mingles with substratum, as PKI/trust/TLS is required or very desirable for VPN/HTTPS etc.

1. Create root CA
   `xkcdpass --delimiter - --numwords 4 > root-ca.pass`
   `step certificate create "ariel@richtman.au" ./root-ca.pem ./root-ca-key.pem --profile root-ca --password-file ./root-ca.pass`
1. Make node directories cause this is going to get messy
   `<nodes.txt xargs mkdir`
1. Create password files
   `<nodes.txt xargs -I% sh -c 'xkcdpass --delimiter - --numwords 4 > "./$1/$1-pass.txt"' -- %`
1. Secure them `chmod 400 *.pass`
1. Create intermediate CAs
   `<nodes.txt xargs -I% step certificate create % ./%/%.pem ./%/%-key.pem --profile intermediate-ca --ca ./root-ca.pem --ca-key ./root-ca-key.pem --ca-password-file root-ca-pass.txt --password-file ./%/%-pass.txt`
1. Distribute the intermediate certificates and keys
1. Secure the root CA, it's a bit hidden but Bitwarden _does_ take attachments.
1. Publish the root CA, with my current setup this meant uploading it to s3.
1. Update the sha256 for the root certificate `fetchUrl` call

- [Smallstep documentation](https://smallstep.com/docs/step-cli/basic-crypto-operations/index.html)
- [Certificate creation/authorization tutorial](https://yuminlee2.medium.com/kubernetes-generate-certificates-for-normal-users-using-certificates-api-7ba71170aa52)

## Topsoil

- [Kubernetes the hard way](https://github.com/kelseyhightower/kubernetes-the-hard-way)

### Cluster access bootstrap

```bash
# Create a client certificate with admin
step certificate create cluster-admin cluster-admin.pem cluster-admin-key.pem \
  --ca ca.pem --ca-key ca-key.pem --insecure --no-password --template granular-dn-leaf.tpl --set-file dn-defaults.json --not-after 8760h \
  --set organization=system:masters
# Construct the kubeconfig file
# Here we're embedding certificates to avoid breaking stuff if we move or remove cert files
kubectl config set-cluster home --server https://fat-controller.local:6443 --certificate-authority ca.pem --embed-certs=true
kubectl config set-credentials home-admin --client-certificate cluster-admin.pem --client-key cluster-admin-key.pem --embed-certs=true
kubectl config set-context --user home-admin --cluster home home-admin
```

### Cluster access (normal)

1. Create private key `openssl genpkey -out klient-key.pem -algorithm ed25519`
1. Create CSR `openssl req -new -config klient.csr.conf -key klient-key.pem -out klient.csr`
1. `export KLIENT_CSR=$(base64 klient.csr | tr -d "\n")`
1. Submit the CSR to the cluster `envsubst -i klient-csr.yaml | kubectly apply -f -`
1. Approve the request `kubectl certificate user approve`

### Cluster node roles

For security reasons, it's not possible for nodes to self-select roles.
We can label our nodes using this:

```
# Fill in the blanks
k label no/fat-controller node-role.kubernetes.io/master=master
k label no/fat-controller kubernetes.richtman.au/ephemeral=false

k label no/mum node-role.kubernetes.io/worker=worker
k label no/mum kubernetes.richtman.au/ephemeral=false

k label no/patient-zero node-role.kubernetes.io/worker=worker
k label no/patient-zero kubernetes.richtman.au/ephemeral=true
k label no/dr-singh node-role.kubernetes.io/worker=worker
k label no/dr-singh kubernetes.richtman.au/ephemeral=true
k label no/smol-bat node-role.kubernetes.io/worker=worker
k label no/smol-bat kubernetes.richtman.au/ephemeral=true

# Now we can clean up shut down nodes
k delete no -l kubernetes.richtman.au/ephemeral=true
```

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

### Addon-manager

Apparently this is deprecated as of years ago but is still shambling along.
As much as I'd love to declaratively bootstrap the cluster it will be less headache to have a one-off CD app install and do the rest declaratively that way.
Anywho - to make addon manager actually work, you need to drop a `.kube/config` file in `/var/lib/kubernetes`.

Removing coredns shenanigans:
`k delete svc/kube-dns deploy/coredns sa/coredns cm/coredns clusterrole/system:kube-dns clusterrolebinding/system:kube-dns`

### Node CSRs piling up

`kubectl get csr --no-headers -o jsonpath='{.items[*].metadata.name}' | xargs -r kubectl certificate approve`

- [GitHub comment](https://github.com/dyrnq/kubeadm-vagrant/issues/4#issuecomment-917590114)

#### Notes

Checking builds manually: `nix build .#nixosConfigurations.fat-controller.config.system.build.toplevel`
Minimal install ~3.2 gigs
Lab-node with master node about 3.2 gb also, so will want more headroom.

Add to nomicon

- fakesha256
- nix-prefetch-url > hash.txt

## Mobile setup

Using tasker

```yaml
Profile: AutoPrivateDNS
         State: Wifi Connected [ SSID:sugar_monster_house MAC:* IP:* Active:Any ]
     Enter: Anon
         A1: Custom Setting [ Type:Global Name:private_dns_mode Value:opportunistic Use Root:Off Read Setting To: ]
     Exit: Anon
         A1: Custom Setting [ Type:Global Name:private_dns_mode Value:hostname Use Root:Off Read Setting To: ]
```

`nix shell nixpkgs#android-tools -c adb shell pm grant net.dinglisch.android.taskerm android.permission.WRITE_SECURE_SETTINGS`

References:

- [StackExchange](https://android.stackexchange.com/a/239471)
- [AdGuard instructions for secret settings](https://adguard.com/kb/adguard-for-android/solving-problems/firefox-certificates/)

## Desktops

### Mac

Trust chain system install:
`sudo security add-trusted-cert -r trustRoot -k /Library/Keychains/System.keychain -d ~/Downloads/root-ca.pem`

#### MBP M2 setup

1. Update everything `softwareupdate -ia`
1. Optionally install rosetta `softwareupdate --install-rosetta --agree-to-license`
   I didn't explicitly install it but it's on there somehow now.
   There was some mention that it auto-installs if you try running x86_64 binaries.
1. Determinant systems install nix `curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install`
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

1. Bootstrapping
  1. do the xcode-install method
  1. Build manually once `nix build github:arichtman/nix#darwinConfigurations.macbook-pro-work.system`
  1. Switch manually once `./result/sw/bin/darwin-rebuild switch --flake .#macbook-pro-work`
1. If bootstrapped, build according to flake `./result/sw/bin/darwin-rebuild switch --flake github:arichtman/nix`

### Universal Blue

some _very_ wip notes about the desktop.

- Installer with nVidia drivers worked ok in simplified mode
- Despite the claims of signing automation for secure boot it still needs to be disabled, 'less you like 800x600.
- Bluetooth pair the speaker though you may have to change the codec in settings > sound
- i ran `bluetoothctl trust $MAC` to try and start off autoconnect
- rpm-ostree upgrade/rebase to Fedora 39 breaks the display driving again.
- I fiddled about in display settings to get orientation of monitors correct
- ran the determinant systems nix installer
- added `trusted-users = @wheel` to `/etc/nix/nix.conf`
- Used `nix shell helix home-manager` to bootstrap
- `home-manager switch --flake . -b backup`
- Installed my root certificate
  `sudo curl https://www.richtman.au/root-ca.pem -o source/anchors/root-ca.pem`
  `sudo update-ca-trust`

#### DNS

Some diagnostic tests for mDNS:

```
export HOST_NAME=fat-controller.local.
# This is our bedrock of truth. It works consistently and can be easily viewed
avahi-resolve-host-name $HOST_NAME
tcpdump udp port 5353 # Optionally -Qin
# Supposedly a good test according to Arch wiki, has not once worked for me.
getent ahosts $HOST_NAME
# Sometimes worked but timed out on a 3rd imaginary server. Most verbose but leaks mDNS queries.
dig $HOST_NAME
# Sometimes worked but not very helpful output.
host $HOST_NAME

# Convenience aliases
alias rollall='sudo systemctl restart NetworkManager systemd-resolved systemd-networkd; sudo systemctl daemon-reload'

alias dtest4='dig -4 $HOST_NAME'
alias dtest6='dig -6 $HOST_NAME'
alias htest4='host -4 $HOST_NAME'
alias htest6='host -6 $HOST_NAME'
alias etest='getent ahosts $HOST_NAME'

alltest() {
  dtest4
  dtest6
  htest4
  htest6
  etest
}

alias nm=nmcli
alias rc=resolvectl
alias as=authselect
```

So, turns out this whole resolution chain is a mess, some things use nsswitch, others don't etc.
We want consistent behaviour and caching, so we need the local stub resolver.
We want it even more if we're switching networks and VPNs as it can hold all the logic for changing shit.

Here's some locations and commands for config.
I tried valiantly to enable it at connection level and in nsswitch but ultimately there was always something that disobeyed the rules.

`/etc/nsswitch.conf`:

This should be managed by `authselect`.
Don't ask why.
Fun fact: apparently the `sssd` daemon totally doesn't need to be running for this to work.
Why is DNS is entwined with an auth config management tool?
Because go fuck yourself, that's why.
~ Poettering, probably.

```sh
authselect list
authselect current
authselect show sssd
# Yields some options
authselect select sssd with-mdns4 with-mdns6
```

`/etc/resolv.conf`:

This one is managed by NetworkManager.
Why is that capitalized?
NFI.
Go fuck yourself!
~ Probably Poettering, again.

I tried manually managing this one, no dice (to do that, stop NetworkManager, and remove the symlink).
Leave it symlinked to `/run/systemd/resolve/stub-resolve.conf`.
That's the managed file that will always point at the local stub resolver.
We can manage the actual settings with `nmcli`.
mDNS is configured per connection, not interface, which I guess makes sense for laptops/WiFi.

```sh
nmcli connection show
# I tried this as 2 (resolve+publish) and I think it clashes with the stub resolver
nmcli conn mod enp3s0 connection.mdns 2
nmcli conn mod sugar_monster_house connection.mdns 2
# Yea it breaks v4 resolution somehow
# Not sure about this one... In theory we lose the domains config as well as our Unbound upstream,
#   but resolved should have us covered? domain search might need to happen at the origin call site though.
nmcli conn mod enp3s0 ipv4.ignore-auto-dns no
nmcli conn mod enp3s0 ipv6.ignore-auto-dns no
```

Oh, the stub resolver doesn't actually run on `localhost:53`.
It's `127.0.0.53` (and actually `.54` also, according to `man 8 systemd-resolved.service`).
Can ya guess why?
Yup. Had enough self-love yet?
Keep reading.

`/etc/systemd/network/*.network`:

You can write files like:

```ini
[Network]
DHCP=yes
Domain=local internal
```

Except when I experimented `resolvectl` didn't edit the file and editing the file didn't show in `resolvectl` output.
So go figure.

I honestly can't keep track of what this is relative to _NetworkManager_.
There is a service, `systemd-networkd`.
By the way, `systemd-resolved` *used* to be controlled by `systemd-resolve`.
It's now `resolvectl`.
Guess I'm not mad about that one.
Now the fact that mDNS is configured per _interface_ and not _connection_ like before?
Get fuuuuuucked.
Oh and the daemon only listens on IPv4 (at least by default).
GFY!

```sh
sudo resolvectl mdns enp0s3 yes
sudo resolvectl domain enp0s3 local internal
echo 'DNSStubListenerExtra=[::1]:53' | sudo tee -a /etc/systemd/resolved.conf
```

`/etc/NetworkManager`:

Whatever.

What worked in the end?
Well, still getting some odd behaviour with `host` and IPv6 but...
No files in `/etc/systemd/network`.
Disable `networkd`.
Resolvectl set +mdns.
Symlinked `/etc/resolv.conf` to the `resolved` stub file.
Configured `resolved`.
Avahi daemon enabled and running with defaults.

```
sudo systemctl disable --now systemd-networkd
sudo systemctl mask systemd-networkd
sudo systemctl daemon-reload
```

Final `/etc/systemd/resolved.conf`:

```ini
[Resolve]
DNS=192.168.1.1,2403:580a:e4b1:0:aab8:e0ff:fe00:91ef
Domains=local internal
MulticastDNS=yes
DNSStubListenerExtra=[::1]:53
```

References:

- [Some helpful soul](https://infosec.exchange/@ds/112663636510469329)
- [StackOverflow answer](https://unix.stackexchange.com/a/442599)
- [Arch wiki page](https://wiki.archlinux.org/title/Domain_name_resolution)
- [Blog post](https://wlog.viltstigen.se/articles/2021/05/02/mdns-for-linux/)
- [Arch forum thread](https://bbs.archlinux.org/viewtopic.php?id=271103)
- So many more misc. pages

### Desktop Todo

- Switch to LibreWolf
- Fix Firefox image pasting
- Get CLI clipboard access
  [post](https://fosstodon.org/@ferki/112868797150769449)
- Learn about universal blue/ostree and decide if I want to keep this
- fix autoshift on my keyboard
- find the proper fix to not sourcing the nix-daemon script that sets `PATH` correctly
- look into errors running `tracker-miner-fs-3.service`
- Work out how to uninstall `nano-default-editor` `rpm-ostree override remove`
- Fix Zellij exits still leaving you in a Bash session.
- Make Alacritty visible on the launch pad or whatever it's called
- Fix CLI history suggestions
- ~~Work out how to get my usual home setup on here (aliases, shell, apps etc)~~
  I've mostly got a handle on how Nix + Home-manager are playing alongside Silverblue
- ~~Fix Helix system clipboard yank~~
  Just works in Alacritty?
- ~~Fix zellij system clipboard copy~~
  Works fine in Alacritty?
- ~~Fix alacritty no suitable GL error~~
  Did some dirty hax with `nixGLIntel`, whatever, it's a complex and long-standing OpenGL on non-Nix systems issue.
- ~~Decide if I want to keep nushell~~
  I don't. I'm sure it's cool but I need to work on too many systems and environments that won't be compatible.
- ~~Remove the nushell banner~~
- ~Work out how to switch my shell to nushell properly...
  or not https://github.com/fedora-silverblue/issue-tracker/issues/307#issuecomment-1173092416
  `/etc/shells` doesn't have it cause it's installed in user space by home-manager.
  We can use `lchsh` or `usermod` but it's under our nix profile bin dir, not a simple location like `/usr/bin`~
  It's justifiable like this.

## Nix References

- [Opinionated flake structure](https://github.com/snowfallorg/lib)
- [Home-manager configuration options](https://nix-community.github.io/home-manager/options.html)
- [Misterio77's starter configs](https://github.com/Misterio77/nix-starter-configs)
- Just generally sucking at it, spelunking `nixpkgs` and `NixOS-WSL` source Nix files
- [Jake Hamilton videos](https://www.youtube.com/@jakehamiltondev)
- [Nebucatnetzer's config](https://git.2li.ch/Nebucatnetzer/nixos/)
- [Post about inline nix use helm](https://hdev.im/@farcaller/113018001043836518)
