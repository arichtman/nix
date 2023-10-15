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

Be forewarned.

1. Intermediate CAs
1. `etcd`
1. `kube-apiserver`

#### Meta stuff

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

#### Intermediate CAs

These only need a couple of specifics, mostly the capability to be a CA/sign other certs.
I like setting the path length restriction so the trust chain can't be ported any further.

```
step certificate create kubernetes-ca ./ca.pem ./ca-key.pem  --ca ./root-ca.pem --ca-key ./root-ca-key.pem --ca-password-file root-ca-pass.txt --insecure --no-password --template granular-dn-intermediate.tpl --set-file dn-defaults.json --not-after 2160h
step certificate create etcd-ca ./etcd.pem ./etcd-key.pem  --ca ./root-ca.pem --ca-key ./root-ca-key.pem --ca-password-file root-ca-pass.txt --insecure --no-password --template granular-dn-intermediate.tpl --set-file dn-defaults.json --not-after 2160h
```

Notes:

- You can just use `--profile intermediate-ca` but then the handful that require a specific organization set would be black sheep.
- I'm _pretty_ sure you can only practically use one intermediate CA for all nodes, though it may be possible to bundle stuff.
  I've had enough punishment and I can't see a use case where it would make sense.
- It _may_ be possible to use the same int CA from k8s for etcd.
  I got pretty far doing that but at one point the k8s CA was being used to authenticate clients and the SAN had to include etcd's hostname.
  This kinda smelled bad enough for me to just go with the recommended way.
- The templating thing feels overkill, I wonder if I could have just constructed the DN and put it in the subject line.
  I do like the way it has defaults that can be optionally overrriden.
- I went spelunking the Smallstep repos and found the built-in templates in the crypto repo under `x509Util`.

#### etcd

This one's pretty easy actually.
We need one leaf for TLS and one leaf for the api server client authentication.

The tricky bit is we need to set **just** the organization in the DN to be something special.
Check the official Kubernetes documentation for a table of certificate requirements like this.

```
# etcd TLS
step certificate create etcd etcd-tls.pem etcd-tls-key.pem --ca etcd.pem --ca-key etcd-key.pem \
  --insecure --no-password --template granular-dn-leaf.tpl --set-file dn-defaults.json --not-after 2160h --bundle \
  --san patient-zero --san patient-zero.local --san localhost --san 127.0.0.1 --san ::1 --san etcd.local
# kube-apiserver
step certificate create kube-apiserver-etcd-client kube-apiserver-etcd-client.pem kube-apiserver-etcd-client-key.pem \
  --ca etcd.pem --ca-key etcd-key.pem --insecure --no-password --not-after 2160h \
  --template granular-dn-leaf.tpl --set-file dn-defaults.json --set organization=system:masters
```

Ok, we should now be able to enable `etcd` and point it at those files.
I used `extraConf` and forked Nixpkgs to be able to point at arbitrary files.
Probably don't do this.

```
extraConf = {
  CERT_FILE = "/var/lib/kubernetes/secrets/etcd-tls.pem";
  KEY_FILE = "/var/lib/kubernetes/secrets/etcd-tls-key.pem";
  CLIENT_CERT_AUTH = "true";
  TRUSTED_CA_FILE = "/var/lib/kubernetes/secrets/etcd.pem";
  PEER_CERT_FILE = "/var/lib/kubernetes/secrets/etcd-tls.pem";
  PEER_KEY_FILE = "/var/lib/kubernetes/secrets/etcd-tls-key.pem";
};
listenClientUrls = [
  # errr the kube-apiserver seems to be using ipv4 loopback?
  "https://127.0.0.1:2379"
  "https://[::1]:2379"
  # Your server's IP
  "https://192.168.1.240:2379"
];
```

Once that's confirmed running we can test it using our certificates and the conveniently-installed `etcdctl`.
`etcdctl --cacert ca.pem --cert kube-apiserver-etcd-client.pem --key  kube-apiserver-etcd-client-key.pem --endpoints patient-zero:2379 auth status`

Final step is to close the permissions.
`chown etcd: etcd*; chmod 400 etcd-key.pem; chmod 444 etcd.pem`
Note that the intermediate public certificate must be readable by kubernetes user, or it's group if you want to get fancy.

Notes:

- I'm not sure I'd bother doing different certificates per-node or not.
  Might help with traceability in the logs for etcd client at least.
- I need to find a nicer way to collate and add the SANs for TLS. Probably nixable.
- Adding loopback and localhost to SANS seems, off.
- I thought about adding the private IP to the SANs but really, what's the indirection of DNS for?
- If using any more intermediate trust in the TLS chain, you'll probably have to bundle the intermediates.
- I don't like having the private IP in the listenUrls, ideally they should be able to be dynamically assigned. TODO
- I had some odd behaviour with it using `127.0.0.2` for loopback. Which is valid but not a listen address we set.
- There's a warning here about serving both gRPC and HTTPS on a single port. TODO
- Deploying services with broken secret file permissions and known failures is bit wonky.
  It's required however, as the users and groups must exist for us to assign permissions on the files.
  It's a Nix thing, pay no mind.

#### kube-apiserver

This one's a beast, since it's basically the heart of the cluster, being the only thing that's allowed to talk to etcd.

First up we have some public certificates only.
The _client ca file_ and _kubelet certificate authority_ can just be the cluster's intermediate CA.
The _etcd ca file_ is `etcd`'s dedicated intermediate CA.

The _etcd certfile_ and _etcd keyfile_ are the leaf client auth certificates we generated in the `etcd` step.

We'll need a few new certificates for this one, all leaf type and only one for HTTPS.

```
# For the actual API server's HTTPS
step certificate create kube-apiserver kube-apiserver-tls.pem kube-apiserver-key.pem --ca ca.pem --ca-key ca-key.pem \
  --insecure --no-password --template granular-dn-leaf.tpl --set-file dn-defaults.json --not-after 2160h --bundle \
  --san patient-zero --san patient-zero.local --san localhost --san 127.0.0.1 --san ::1 \
  --san kubernetes --san kubernetes.default --san kubernetes.default.svc \
  --san kubernetes.default.svc.cluster --san kubernetes.default.svc.cluster.local
# For client authentication to kubelets
step certificate create kube-apiserver-kubelet-client kube-apiserver-kubelet-client.pem kube-apiserver-kubelet-client-key.pem \
  --ca ca.pem --ca-key ca-key.pem --insecure --no-password --template granular-dn-leaf.tpl --set-file dn-defaults.json --not-after 2160h \
  --set organization=system:masters
# For client authentication to the proxy services
step certificate create kube-apiserver-proxy-client kube-apiserver-proxy-client.pem kube-apiserver-proxy-client-key.pem \
  --ca ca.pem --ca-key ca-key.pem --insecure --no-password --template granular-dn-leaf.tpl --set-file dn-defaults.json \
  --not-after 2160h
```

The last thing we need is a public & private key pair, encoded in x509 for signing service account tokens.

`openssl req -new -x509 -days 365 -newkey rsa:4096 -keyout service-account-key.pem -sha256 \
  -out service-account.pem -nodes \
  -multivalue-rdn -subj /CN=Australia/O=Richtman/OU=Ariel/CN=kubernetes-service-accounts`

Now we can configure that and it should be talking to `etcd` A-OK.
Again, **do not repeat this hackery for anything serious**.

For cleanup fix the certificate and secret permissions.
```
# Own your certificates
chown kubernetes: kube-apiserver*
chmod 400 kube-apiserver*

# Own the service account key pair
chown kubernetes: service-account*
chmod 400 service-account-key.pem
chmod 444 service-account.pem

# Take ownership of the int-ca files
chown kubernetes: ca*.pem
# Protect the ca key
chmod 400 ca-key.pem
# Leave the public cert open
chmod 444 ca.pem
```

```
  serviceAccountKeyFile = "/var/lib/kubernetes/secrets/service-account.pem";
  serviceAccountSigningKeyFile = "/var/lib/kubernetes/secrets/service-account-key.pem";
  extraOpts = ''
    --client-ca-file=/var/lib/kubernetes/secrets/ca.pem \
    --etcd-cafile=/var/lib/kubernetes/secrets/etcd.pem \
    --kubelet-certificate-authority=/var/lib/kubernetes/secrets/ca.pem \
    --etcd-certfile=/var/lib/kubernetes/secrets/kube-apiserver-etcd-client.pem \
    --etcd-keyfile=/var/lib/kubernetes/secrets/kube-apiserver-etcd-client-key.pem \
    --tls-cert-file=/var/lib/kubernetes/secrets/kube-apiserver.pem \
    --tls-private-key-file=/var/lib/kubernetes/secrets/kube-apiserver-key.pem \
    --kubelet-client-certificate=/var/lib/kubernetes/secrets/kube-apiserver-kubelet-client.pem \
    --kubelet-client-key=/var/lib/kubernetes/secrets/kube-apiserver-kubelet-client-key.pem \
    --proxy-client-cert-file=/var/lib/kubernetes/secrets/kube-apiserver-proxy-client.pem \
    --proxy-client-key-file=/var/lib/kubernetes/secrets/kube-apiserver-proxy-client-key.pem \
    --external-hostname=patient-zero
  '';
```

Notes:

- A few of the last ones could probably be the same certificate, but it's a bit nicer probably in tracing to have different CNs.
  Some services auth and assign the username as the CN/DN, which could lead to a lot of confusion.
- A bunch of those SANs are just suggestions from the docs, they probably need actual DNS entries to work. TODO
- I definitely wonder now at the addition of SANs for loopback IPs, that feels weird for HTTPS.
- I had hoped we could just `ssh-keygen`, but alas it has to be x509 for the service account pair.
- I have no idea if the service account pair should be rotated or even can be, given that it's used for verification too.
  I _think_ it's possible to use one of the other certificates that we have both sides of. Unsure.
- I'm not actually sure the service account public key has to be open but it would make sense if anything wanted to verify the tokens

#### Other components

```bash
# Note the Subject.CommonName being set not by flags but required arguments
step certificate create system:node:patient-zero kubelet-apiserver-client.pem kubelet-apiserver-client-key.pem \
  --ca ca.pem --ca-key ca-key.pem --insecure --no-password --template granular-dn-leaf.tpl --set-file dn-defaults.json \
  --not-after 2160h --set organization=system:nodes
step certificate create system:kube-scheduler scheduler-apiserver-client.pem scheduler-apiserver-client-key.pem \
  --ca ca.pem --ca-key ca-key.pem --insecure --no-password --template granular-dn-leaf.tpl --set-file dn-defaults.json \
  --not-after 2160h
step certificate create system:kube-proxy proxy-apiserver-client.pem proxy-apiserver-client-key.pem \
  --ca ca.pem --ca-key ca-key.pem --insecure --no-password --template granular-dn-leaf.tpl --set-file dn-defaults.json \
  --not-after 2160h --set organization=system:node-proxier
step certificate create kube-scheduler scheduler-tls.pem scheduler-tls-key.pem --ca ca.pem --ca-key ca-key.pem \
  --insecure --no-password --template granular-dn-leaf.tpl --set-file dn-defaults.json --not-after 2160h --bundle \
  --san patient-zero --san patient-zero.local --san localhost --san 127.0.0.1 --san ::1
```

#### Onwards

I worked a bit on `kube-scheduler` but it's missing an argument for setting the trusted CA file.
It's kubeconfig is a generic one generated the same for every service.
This will need some actual Nix work to get going.

From here forwards you should have a reasonably clear hammer to hit most cert requirements with.
It's basically either for HTTPS and needs a SAN or it's for client auth and it _may_ need the `O` property set.

General notes:

- You could probably just set the organization to `system:masters` on _every_ cert but it feels brutish.
- My DNS name has been kinda hard-coded into this, I need to genericize it but probably a Nix thing. TODO
- I should update the Nix module reference to `glog` to `klog` and the [URL](https://kubernetes.io/docs/concepts/cluster-administration/system-logs/#log-verbosity-level) too.
  TODO
- CSR/config files would be nicer for this, but not as valuable to my use case.
- I didn't bother backing up the intermediate CAs, they're essentially disposable.
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
