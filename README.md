# Nix

**Stay frosty like Tony**

A home for my system configurations using Nix Flakes
Be warned, I'm still learning and experimenting.
Nothing here should be construed as a model of good work!
... yet.


## Known issues/TODO

- ~Recurring WSL2 systemd issue, we have a fix but it's ugly.~ Work machine is off Windows, home we now have a dedicated NixOS box.
- Look into `buildEnv` over `devShell`
- Perhaps actually put something useful in myShell
- Maybe test out packaging a toy app/repo

## Use

## Mac

Current WIP / notes:

system-level mac config under systems/x86_64-darwin/${system}/default.nix

homes/my_home/default.nix gets applied to everything?
If you don't want to have a home module you can pass user config in the system file via snowfallorg.user.${name}.home.config.

I think if we want platform-specific stuff we can either make a new module and do config = mkIf and enable in system's default.nix via snowfall org OR we can do some conditional config in the existing module.
There should be some like system.isDarwin system.isLinux options there.
I think logically it makes sense to moduarize stuff like zsh enablement and config but not at the moment.

Under homes/x86_64-darwin/arichtman@macbookpro/default.nix there seems to be some specific-to-that-combo config.
I haven't confirmed why some of those settings don't apply but it may be zsh vs bash issue.

### MBP M2 setup

1. Update everything `softwareupdate -ia`
1. Optionally install rosetta `softwareupdate --install-rosetta --agree-to-license`
  (I didn't)
1. Determinant systems install nix `curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install`
1. # Until this is resolved https://github.com/LnL7/nix-darwin/issues/149
  `sudo mv /etc/nix/nix.conf /etc/nix/.nix-darwin.bkp.nix.conf`
1. Nix-Darwin build and run installer
```
nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A installer
./result/bin/darwin-installer
```
edit default configuration.nix? n
# Accept the option to manage nix-darwin using nix-channel or else it bombs
manage using channels? y
add to bashrc y
add to zshrc? y
create /run? y
# a nix-channel call will now fail
1. Bootstrapping
  1. do the xcode-install method
  1. Build manually once `nix build github:arichtman/nix#darwinConfigurations.macbook-pro-work.system`
  1. Switch manually once `./result/sw/bin/darwin-rebuild switch --flake .#macbook-pro-work`
1. If bootstrapped, build according to flake `./result/sw/bin/darwin-rebuild switch --flake github:arichtman/nix`?

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

In our shiny new install we can set up direct from GitHub!

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
1. Save and reboot
1. Hit escape to select boot option of USB (esc maybe not required)
1. Follow the instructions to install NixOS
  - 23.05 (but higher is fine)
  - User _nixos_
  - Same password for `root`
  - Auto login (QoL but consult your threat model)
1. Modify /etc/nixos/configuration.nix enough to to what you need
1. Download flake repo from github

Upcoming:

- Maybe enable flakes and rebuild from github

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
