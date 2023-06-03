# Nix

**Stay frosty like Tony**

A home for my system configurations using Nix Flakes
Be warned, I'm still learning and experimenting.
Nothing here should be construed as a model of good work!
... yet.


## Known issues/TODO

- Recurring WSL2 systemd issue, we have a fix but it's ugly.
- homes/shared.nix not being incorporated suddenly???
- Incorporating the mac configuration into the central flake.
- Look into `buildEnv` over `devShell`

## Use

## Mac

Current WIP / notes:

system-level mac config under systems/x86_64-darwin/${system}/default.nix

homes/my_home/default.nix gets applied to everything? and we pass the config via snowfallorg.user.${name}.home.config.
I think if we want platform-specific stuff we can either make a new module and do config = mkIf and enable in system's default.nix via snowfall org OR we can do some conditional config in the existing module.
There should be some like system.isDarwin system.isLinux options there.
I think logically it makes sense to moduarize stuff like zsh enablement and config but not at the moment.

Under homes/x86_64-darwin/arichtman@macbookpro/default.nix there seems to be some specific-to-that-combo config.
I haven't confirmed why some of those settings don't apply but it may be zsh vs bash issue.

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

## Notes

The VSCode server used to need to be enabled and either a reboot or manually started.
However on my 22.11 install just now it was working fine.
If I need to revisit it, go check the Git history.

## References

- [VSCode server workaround](https://github.com/msteen/nixos-vscode-server)
- [Opinionated flake structure](https://github.com/snowfallorg/lib)
- [Home-manager configuration options](https://nix-community.github.io/home-manager/options.html)
- [Misterio77's starter configs](https://github.com/Misterio77/nix-starter-configs)
- Just generally sucking at it, spelunking `nixpkgs` and `NixOS-WSL` source Nix files
- [Jake Hamilton videos](https://www.youtube.com/@jakehamiltondev)
