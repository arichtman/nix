# Nix

A home for my system configurations using Nix Flakes

Upcoming: Moving multiple machine configurations into a central Flake.

Be warned, I'm still learning and experimenting.
Nothing here should be construed as a model of good work!
... yet.

## Use

### WSL

So 22.05 is out of support but no release on GitHub yet, luckily they give instructions and building 22.11 tarball is pretty easy + quick.
Follow that and do the import shuffle.
Make sure to backup anything valuable.

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
home-manager switch --flake github:arichtman/nix/
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

I'm still not sure the best way to do system config.
If I git clone into `/etc/nixos` and replicate ownership then I can't push any changes, since root user doesn't (and shouldn't) have my `gitconfig` or SSH keys.
Symlinking files in was fiddlier and caused issues with the build context, cause it followed the links.

## References

- [VSCode server workaround](https://github.com/msteen/nixos-vscode-server)
- [Opinionated flake structure](https://github.com/snowfallorg/lib)
- [Home-manager configuration options](https://nix-community.github.io/home-manager/options.html)
- [Misterio77's starter configs](https://github.com/Misterio77/nix-starter-configs)
- Just generally sucking at it, spelunking `nixpkgs` and `NixOS-WSL` source Nix files

We had some pretty gnarly WSL/SystemD errors before.
I started diving on them but didn't get deep enough to find an answer.
Anyways, seems like it's resolved now but they're pretty filthy about having to do this workaround for WSL.
https://github.com/nix-community/NixOS-WSL/issues/185
