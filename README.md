# Nix

**Stay frosty like Tony**

A home for my system configurations using Nix Flakes
Be warned, I'm still learning and experimenting.
Nothing here should be construed as a model of good work!
... yet.

## Known issues/TODO

- Look into where makes sense to bootstrap secrets/vault/trust
- Convert nodes to use ssh certificates for client authentication and server certificates instead of TOFU
- Look into `buildEnv` over `devShell`
- Test out packaging a toy app/repo
- ~Get a container image build with nix going~
  [Jamey blog](https://jamey.thesharps.us/2021/02/02/docker-containers-nix/)
  [Amos's example](https://jamey.thesharps.us/2021/02/02/docker-containers-nix/)
- Look into roles anywhere for DDNS
  [docs](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_common-scenarios_non-aws.html)
- ~Pull common kubernetes config out into another module~
- ~Possibly rewrite the Kubernetes module(s)~
- ~Fix addonManager not finding anything to apply~
- Use the kubernetes mkCert and mkKubeConfig functions [example](https://github.com/pl-misuw/nixos_config/blob/cce24d10374f91c2717f6bd6b3950ebad8e036d5/modules/k8s.nix#L11)
- `system.autoUpgrade.enable` make it Wednesday morning, after our scheduled CI flake updates
- Look into kubernetes managing itself with etc+cluster CAs in `/etc/kubernetes/pki`
- See about CSR auto-approval [project](https://github.com/postfinance/kubelet-csr-approver)
- Look into reducing apiserver kubelet permissions to `kubeadm:cluster-admins`
- Work out graceful node shutdown to remove them from the API server
- Swap my user to a lower privilege one on Proxmox and OPNsense
- ~Work out what's to replace addon-manager~
  It's sig-addonmanager, I think.
  That can be a static pod on the control plane and in turn bootstrap FluxCD/Cilium.
- ~Set up VPN in OPNsense~
  WG and OpenVPN working.
  Might to IPsec too or further tuning.
- Swap kubernetes to IPv6
- Set up IPv6 ingress and firewalling
- BGP peer cluster to router?
- See about nixos on-boot auto disk resize (and add to template!)
- ~Work out watchdog on Opnsense BSD~
  HW watchdog configured on the Topton N100.
  Monitoring it to see if it locks up still.
- See about more modern watchdog options - apparently this one is ancient 32 bit PCI
- Maybe [Tailscale OPNsense](https://tailscale.com/kb/1097/install-opnsense)

### Kubernetes certificate setup

Here's a dump of some utility stuff for developing this.

```
# Send over all the keys and open permissions
function keySync {
  rsync etcd*.pem "${1}.local:/home/nixos/kubernetes"
  rsync kube*.pem "${1}.local:/home/nixos/kubernetes"
  rsync ca*.pem "${1}.local:/home/nixos/kubernetes"
  rsync flannel*.pem "${1}.local:/home/nixos/kubernetes"
  rsync proxy-*.pem "${1}.local:/home/nixos/kubernetes"
  ssh "${1}.local" sudo cp "./kubernetes/*.pem" /var/lib/kubernetes/secrets
  ssh "${1}.local" sudo chown kubernetes: "/var/lib/kubernetes/secrets/*.pem"
  ssh "${1}.local" sudo chown etcd: "/var/lib/kubernetes/secrets/etcd*.pem"
  ssh "${1}.local" sudo chmod 444 "/var/lib/kubernetes/secrets/*.pem"
  ssh "${1}.local" sudo chmod 400 "/var/lib/kubernetes/secrets/*key*.pem"
}

# Check a services logs from the last run
function logs { journalctl _SYSTEMD_INVOCATION_ID=$(systemctl show -p InvocationID --value $1) ; }

alias sci='step certificate inspect'

# TCP check
cat < /dev/tcp/fat-controller.local/2379

# Checking served certificates
openssl s_client -showcerts -connect localhost:2379 # -servername $NAME (if facing SNI)
```

General notes:

- My DNS name has been kinda hard-coded into this, I need to genericize it but probably a Nix thing. TODO
- I should update the Nix module reference to `glog` to `klog` and the [URL](https://kubernetes.io/docs/concepts/cluster-administration/system-logs/#log-verbosity-level) too.
  TODO
- I could also have added the root CA to my hugo's static files but it's not _really_ part of the website.
  I'm probably going to move off the s3+netlify combo once my platform is set up, it's kinda limited.

Initial kubeconfig for access

```
kc config set-cluster mine --certificate-authority=$sd/ca.pem --embed-certs=true --server=https://fat-controller.local:6443

kc config set-credentials admin --client-certificate=admin.pem --client-key=admin-key.pem

kc config set-context mine --cluster=mine --user=admin

#May also have to untaint stuff
kc taint nodes fat-controller.local node.kubernetes.io/not-ready-
```

#### References

- [Smallstep cli docs](https://smallstep.com/docs/step-cli/reference/certificate/create/)
- [k8s certificate guide](https://kubernetes.io/docs/setup/best-practices/certificates/#single-root-ca)
- [k8s apiserver cli reference](https://kubernetes.io/docs/reference/command-line-tools-reference/kube-apiserver/)
- [k8s tls rotation procedure](https://kubernetes.io/docs/tasks/tls/certificate-rotation/)
- [Resetting easyCerts/PKI](https://github.com/NixOS/nixpkgs/issues/59364#issuecomment-485249797)
- [NixOS wiki on k8s](https://nixos.wiki/wiki/Kubernetes)
- [Broken etcd hack to fix k8s module](https://github.com/NixOS/nixpkgs/issues/124037#issuecomment-846538656)
- [NixOS issue on poor k8s documentation](https://github.com/NixOS/nixpkgs/issues/39327)
- [NixOS forum post on k8s config](https://discourse.nixos.org/t/kubernetes-using-multiple-nodes-with-latest-unstable/3936)

## Home lab setup

We will reserve the bottom 10 of the subnet range for networking gear.
We'll use the next ten for static stuff, and the rest can be DHCP.
The reason for this is the core elements need fixed IPs so I can access even if DHCP and DNS is down.

Opnsense 192.161.1.1
Asus 192.168.1.2
Topton 192.161.1.11

Pre-requisites:

- Followed instructions from NixOS to flash ISO to USB

### HP EliteDesk 800 G3 Micro/Mini.

1. Mash F10 to hit the bios (this was a thowback and a pain to do)
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
1. Nix rebuild switch to the flake's config.
1. Confirm SSH remote access is working.
1. Reboot and enter bios.
   - Turn fast boot back on
   - Set boot delay to 0
   - Disable UEFI boot priority. If we need to boot from USB we'll reenter the BIOS.
1. Save BIOS changes and one last confirmation that the system boots and is remotable.
1. Move the machine to it's final home.
1. Remotely retrieve the hardware configuration and commit it to the flake repo.

### Topton N100

1. Mash `F10` (?) to enter BIOS
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
   If GRUB, `sed -i -r -e 's/(GRUB_CMDLINE_LINUX_DEFAULT=")(.*)"/\1\2 intel_iommu=on iommu=pt"/' /etc/default/grub`
1. `echo 'vfio
    vfio_iommu_type1
    vfio_pci
    vfio_virqfd' >> /etc/modules`
1. Reboot to check config

If I check /etc/grub.d/000_ proxmox whatever it says `update-grub` isn't the way and to use `proxmox-boot-tool refresh`.
It also looks like there's a specific proxmox grub config file under `/etc/default/grub.d/proxmox-ve.cfg`.
I don't expect it _hurts_ much to have iommu on as a machine default, and we're not booting anything else...
Might tidy up the sed config command though.
Looking at the systemd we could probably do both without harm.
That one's also using the official proxmox command.

References:

- [Proxmox package repo docs](https://pve.proxmox.com/wiki/Package_Repositories)
- [Servethehome net passthru tutorial](https://www.servethehome.com/how-to-pass-through-pcie-nics-with-proxmox-ve-on-intel-and-amd/)

### Proxmox

Previously we considered LXC containers.
We've since been advised it's not worth the hassle.
Check git history for prior notes.

#### Disk setup

We did run `mkfs -t ext4` but it didn't allow us to use the disk in the GUI.
So using GUI we wiped disk and initialized with GPT.

For the USB rust bucket we found the device name with `fdisk -l`.
~Then we `mkfs -t ext4 /dev/sdb`, followed by a `mount /dev/sdb /media/backup`.~
Never mind, same dance with the GUI, followed by heading to Node > Disks > Directory and creating one.

Use `blkid` to pull details and populate a line in `/etc/fstab` for auto remount of backup disk.
[Ref](https://www.baeldung.com/linux/automount-partitions-startup)

#### Opnsense

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
1. Configure Upbound DNS service
   - enable DNSSEC
   - enable DHCP lease registration
   - Disallow system nameservers in DoT and add records with blank domains+port 853
   - Enable blocklist and use OISD Ads only (to be experimented with)
   - Enable data capture
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
1. System > settings > cron
   - once daily to update the block lists
   - once weekly after the backup is taken (this ensures we can restore)
1. Test
   - DNS redirection:
      - Unbound host override bing.com to something
      - Check this returns the override `dig +trace @4.4.4.4 bing.com`
   - Ad blocking https://d3ward.github.io/toolz/adblock.html
1. If enabling BGP run `sysctl kern.ipc.maxsockbuf=16777216` as plugin post-install message suggests.
1. Install plugins:
   - NextCloud backup
   - FRR BGP
   - Prometheus exporter
   - DynamicDNS client
   - [themes]

TODO:

1. ~See about AAAA records or how to IPv6 resolve internal hosts~ It's either DHCPv6 or mDNS
1. ~Look into vLAN~ Requires managed switches and more interfaces than I have.
1. ~Look into removing NAT~ Not gonna happen for IPv4
1. ~Set up VPN~
1. Set up non-root user/s
1. ~Think about DoH https://homenetworkguy.com/how-to/configure-dns-over-https-dnscrypt-proxy-opnsense/~ Implemented along with reverse-proxy trapping.

Notes:

I will revisit the resources supplied after running the box for a bit.

Bare metal recommendation is multi-core so that system activities don't have to impact CPU network activities.
Because we're virtualizing I don't want 2 schedulers fighting each other, so I'll rely on the hypervisor's scheduling.
Might be worth revisiting or pinning a full core to the VM.

References:

- [Reddit performance comment](https://www.reddit.com/r/OPNsenseFirewall/comments/guo2iz/comment/fskpk76)
- [DNS tutorial](https://homenetworkguy.com/how-to/redirect-all-dns-requests-to-local-dns-resolver/)
- [Unbount DoT tutorial](https://homenetworkguy.com/how-to/configure-dns-over-tls-unbound-opnsense/)

#### Virtualized Nixos Node Bootstrap

1. Use GUI installer to deploy, cli one's a pain, 12GiB storage minimum, 4 cores/8GiB ram (min 4+ GiB). We'll scale it down later.
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
   `mkdir ~/.ssh && curl https://github.com/arichtman.keys -o ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys`
1. Upgrade the system
   `sudo nixos-rebuild switch --upgrade --upgrade-all`
1. Reboot to test
1. Clear history
   `sudo nix-rebuild list-generations`
   `sudo rm /nix/var/nix/profiles/system-#-profile`
   `sudo nix-collect-garbage --delete-old`
1. Adjust hardware down to 1/2GiB.
1. Make template

Re-IDing a proxmox vm:

1. Stop VM
1. Get storage group name `lvs -a`
1. Rename disk `lvrename prod vm-100-disk-0 vm-999-disk-0`
1. Enter `/etc/pve/nodes/proxmox/qemu-server`
1. Edit conf file to use renamed disk.
1. Move conf file to new id

Adding watchdog to a proxmox VM

1. Add `watchdog: model=i6300esb,action=reset` to the conf file in `/etc/pve/qemu-server/`.
1. Stop and start the VM.

See references for details.

#### Cluster access bootstrap

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

#### Cluster access (normal)

1. Create private key `openssl genpkey -out klient-key.pem -algorithm ed25519`
1. Create CSR `openssl req -new -config klient.csr.conf -key klient-key.pem -out klient.csr`
1. `export KLIENT_CSR=$(base64 klient.csr | tr -d "\n")`
1. Submit the CSR to the cluster `envsubst -i klient-csr.yaml | kubectly apply -f -`
1. Approve the request `kubectl certificate user approve`

#### Cluster node roles

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

#### Addon-manager

Apparently this is deprecated as of years ago but is still shambling along.
As much as I'd love to declaratively bootstrap the cluster it will be less headache to have a one-off CD app install and do the rest declaratively that way.
Anywho - to make addon manager actually work, you need to drop a `.kube/config` file in `/var/lib/kubernetes`.

Removing coredns shenanigans:
`k delete svc/kube-dns deploy/coredns sa/coredns cm/coredns clusterrole/system:kube-dns clusterrolebinding/system:kube-dns`

#### Node CSRs piling up

`kubectl get csr --no-headers -o jsonpath='{.items[*].metadata.name}' | xargs -r kubectl certificate approve`

[Ref](https://github.com/dyrnq/kubeadm-vagrant/issues/4)

#### Calico

***Under Construction***

uninstaller bombs due to insufficient permissions
so does operator running, but not until it installs a buncha shit

```
helm repo add projectcalico https://projectcalico.docs.tigera.io/charts
kubectl create namespace tigera-operator
helm install calico projectcalico/tigera-operator --namespace tigera-operator
```

[Chart](https://github.com/projectcalico/calico/tree/master/charts/tigera-operator)

#### Virtual node disk resize

```bash
nix-shell -p cloud-utils
growpart /dev/sda 1
resize2fs /dev/sda1
```

#### Mobile setup

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

#### Notes

Checking builds manually: `nix build .#nixosConfigurations.fat-controller.config.system.build.toplevel`
Minimal install ~3.2 gigs
Lab-node with master node about 3.2 gb also, so will want more headroom.

Add to nomicon

- fakesha256
- nix-prefetch-url > hash.txt

## Desktops

## Mac

Trust chain system install:
`sudo security add-trusted-cert -r trustRoot -k /Library/Keychains/System.keychain -d ~/Downloads/root-ca.pem`

### MBP M2 setup

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

The networking is fucked for some reason out the box.
Direct connection to the router works-ish. I can access ap and proxmox by their DNS records, but not opnsense.
If I add the switch in the middle I never get any replies to my DHCP requests.
If I set the IP and DNS manually it kinda works. DNS records locally resolve fine directly but not for SSH/firefox/curl.
Anyways, what I did was set IP+DNS on the interface manually.
Then I had to muck with the DNS locally.
I would have just re-ordered /etc/nsswitch.conf but it's under management.
This set it to the same as current but with the mdns feature off entirely.
`sudo authselect select sssd with-silent-lastlog; sudo authselect apply-changes`.
The sssd service is actually dead so I have no idea why this is working but what-THEFUCK-ever at this point.
Finally just for good measure I threw my other static IP boxes into `/etc/hosts` cause fuck this for a joke.
Firefox is being a cunt and won't let me access the services by their DNS records, but IP works.
Because fuck you, apparently.
Yes, I tried turning off DNS security features and setting the local domain.
Gave up and added to /etc/hosts

#### Fixing DNS

https://infosec.exchange/@ds/112663636510469329

```bash
sudo systemctl disable systemd-resolved --now
sudo systemctl stop NetworkManager
# Former symlink `/etc/resolv.conf` = `../run/systemd/resolve/stub-resolve.conf`
sudo rm -f /etc/resolve.conf
sudo systemctl restart NetworkManager
```

TODOs:

- Get cli clipboard access
- Fix Helix system clipboard yank
- Fix zellij system clipboard copy
- Learn about universal blue/ostree and decide if I want to keep this
- ~Work out how to get my usual home setup on here (aliases, shell, apps etc)~
  I've mostly got a handle on how Nix + Home-manager are playing alongside Silverblue
- fix autoshift on my keyboard
- find the proper fix to not sourcing the nix-daemon script that sets `PATH` correctly
- look into errors running `tracker-miner-fs-3.service`
- Fix alacritty no suitable GL error
- ~Decide if I want to keep nushell~
  I don't. I'm sure it's cool but I need to work on too many systems and environments that won't be compatible.
- ~Remove the nushell banner~
- Work out how to uninstall `nano-default-editor` `rpm-ostree override remove`
- Fix Zellij exits still leaving you in a Bash session
- ~Work out how to switch my shell to nushell properly...
  or not https://github.com/fedora-silverblue/issue-tracker/issues/307#issuecomment-1173092416
  `/etc/shells` doesn't have it cause it's installed in user space by home-manager.
  We can use `lchsh` or `usermod` but it's under our nix profile bin dir, not a simple location like `/usr/bin`~
  It's justifiable like this.
- Make Alacritty visible on the launch pad or whatever it's called
- Fix CLI history suggestions

## Cilium references

- https://docs.cilium.io/en/stable/installation/k8s-install-helm/
- https://handbook.giantswarm.io/docs/support-and-ops/ops-recipes/cilium-troubleshooting/
- https://docs.cilium.io/en/stable/operations/troubleshooting/
- https://github.com/cilium/cilium/blob/main/install/kubernetes/cilium/values.yaml
- https://github.com/containerd/containerd/issues/9139
- https://kubernetes.io/docs/tasks/administer-cluster/migrating-from-dockershim/troubleshooting-cni-plugin-related-errors/
- https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/

## Trust chain setup

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

## References

- [Opinionated flake structure](https://github.com/snowfallorg/lib)
- [Home-manager configuration options](https://nix-community.github.io/home-manager/options.html)
- [Misterio77's starter configs](https://github.com/Misterio77/nix-starter-configs)
- Just generally sucking at it, spelunking `nixpkgs` and `NixOS-WSL` source Nix files
- [Jake Hamilton videos](https://www.youtube.com/@jakehamiltondev)
- [Nebucatnetzer's config](https://git.2li.ch/Nebucatnetzer/nixos/)
- [Smallstep documentation](https://smallstep.com/docs/step-cli/basic-crypto-operations/index.html)
- [Kubernetes the hard way](https://github.com/kelseyhightower/kubernetes-the-hard-way)
- [Nixos VM tutorial](https://mattwidmann.net/notes/running-nixos-in-a-vm/)
- [Proxmox vmid change knowledge base article](https://bobcares.com/blog/change-vmid-proxmox/)
- [Certificate creation/authorization tutorial](https://yuminlee2.medium.com/kubernetes-generate-certificates-for-normal-users-using-certificates-api-7ba71170aa52)
- [Proxmox watchdog tutorial](https://it-notes.dragas.net/2018/09/16/proxmox-enable-and-use-watchdog-to-reboot-stuck-servers/)
- [Proxmox CPU selection tutorial](https://www.yinfor.com/2023/06/how-i-choose-vm-cpu-type-in-proxmox-ve.html)
- [OpenVPN setup guide](https://sysadmin102.com/2024/03/opnsense-openvpn-instance-remote-access-ssl-tls-user-auth/())

## Insane IPv6 Plan

![foolish mortals](./native-k8s-ipv6.drawio.svg "What the fuck is this")

### References

- [Cilium with OpnSense blog](https://dickingwithdocker.com/posts/using-bgp-to-integrate-cilium-with-opnsense/)
