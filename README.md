# Nix

**Stay frosty like Tony**

A home for my system configurations using Nix Flakes
Be warned, I'm still learning and experimenting.
Nothing here should be construed as a model of good work!
... yet.


## Known issues/TODO

- Look into where makes sense to bootstrap secrets/vault/trust
- Convert nodes to use ssh certificates for authentication and server certificates
- Look into `buildEnv` over `devShell`
- Perhaps actually put something useful in myShell
- Test out packaging a toy app/repo
- Think about intermediate CA revokation
- Convert nodes to use ssh certificates for authentication and server certificates
- Use the kubernetes mkCert and mkKubeConfig functions [example](https://github.com/pl-misuw/nixos_config/blob/cce24d10374f91c2717f6bd6b3950ebad8e036d5/modules/k8s.nix#L11)
- Pull common kubernetes config out into another module

## Use

## Mac

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

### WSL

So 22.05 is out of support but no release on GitHub yet, luckily they give instructions and building 22.11 tarball is pretty easy + quick.
Follow that and do the import shuffle.
Make sure to back up anything valuable.

```powershell
wsl --unregister NixOS
wsl --import nix --version 2 D:\wsl\NixOS\ .\nixos-wsl-installer.tar.gz
wsl --set-default NixOS
wsl
```

In our shiny new WSL install we can set up direct from GitHub!

```Bash
# Apply directly from git
sudo nixos-rebuild switch --flake github:arichtman/nix#bruce-banner
home-manager switch --flake github:arichtman/nix
# Remove config that might interfere
sudo mv /etc/nixos /etc/nixos.bak

#region Misc.

# Erase history (be sure current config is good)
nix profile wipe-history
# Clean up store
sudo nix store gc
#endregion
```

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

### Kubernetes certificate setup

Here's a dump of some utility stuff for developing this.

```
# Send over all the keys and open permissions
function keySync {
  rsync ./*.pem patient-zero:/home/nixos/kubernetes
  ssh patient-zero sudo cp ./kubernetes/*.pem /var/lib/kubernetes/secrets
  ssh patient-zero sudo chmod 777 /var/lib/kubernetes/secrets/*.pem
}

# Check a services logs from the last run
function logs { journalctl _SYSTEMD_INVOCATION_ID=$(systemctl show -p InvocationID --value $1) ; }

alias sci='step certificate inspect'

# TCP check
cat < /dev/tcp/patient-zero/2379

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
kc config set-cluster mine --certificate-authority=$sd/ca.pem --embed-certs=true --server=https://patient-zero:6443

kc config set-credentials admin --client-certificate=admin.pem --client-key=admin-key.pem

kc config set-context mine --cluster=mine --user=admin

#May also have to untaint stuff
kc taint nodes patient-zero node.kubernetes.io/not-ready-
```

For some reason the flannel bootstrap isn't putting the right files into the manifests directory.
For now I've manually set up the RBAC for flannel.
Just apply the `flannel.yaml`.

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

Pre-requisites:

- Followed instructions from NixOS to flash ISO to USB

Using HP EliteDesk 800 G3 Micro/Mini.

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

## Notes

Checking on WSL `nix build .#nixosConfigurations.patient-zero.config.system.build.toplevel`

Add to nomicon

- fakesha256
- nix-prefetch-url > hash.txt

## References

- [VSCode server workaround](https://github.com/msteen/nixos-vscode-server)
- [Opinionated flake structure](https://github.com/snowfallorg/lib)
- [Home-manager configuration options](https://nix-community.github.io/home-manager/options.html)
- [Misterio77's starter configs](https://github.com/Misterio77/nix-starter-configs)
- Just generally sucking at it, spelunking `nixpkgs` and `NixOS-WSL` source Nix files
- [Jake Hamilton videos](https://www.youtube.com/@jakehamiltondev)
- [Nebucatnetzer's config](https://git.2li.ch/Nebucatnetzer/nixos/)
- [Smallstep documentation](https://smallstep.com/docs/step-cli/basic-crypto-operations/index.html)
- [Kubernetes the hard way](https://github.com/kelseyhightower/kubernetes-the-hard-way)
