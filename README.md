# Nix

A home for my system configurations using Nix Flakes

Yes, I'm aware they're supposed to be in one mega-flake with imports.
For now I'm still learning and experimenting.

## Developing

### WSL

```Bash
# Apply directly from git
sudo nixos-rebuild switch --flake github:arichtman/nix/temp#bruce-banner
# Check status
systemctl status "home-manager-$USER.service"
home-manager switch
# TODO: Work out how the heck to Nixify this?
systemctl --user start auto-fix-vscode-server.service

# Erase history (be sure current config is good)
nix profile wipe-history
# Clean up store
sudo nix store gc
```

## Notes

TODO: Try setting the system up directly from GitHub `sudo nixos-rebuild build --flake github:arichtman/nix/temp#bruce-banner`

I can't locate a "good" way of ensuring that VSCode service is *started* when we switch configurations.
It's _enabled_, so it _should_ start on next boot.
I figure since we're still running imperative commands during bootstrap it'll have to do.
Maybe we use this `serviceConfig` oneshot thing? https://github.com/nix-community/NixOS-WSL/issues/185#issuecomment-1360337884

I tried convenience symlinking the system configuration files to our cloned repo.
In theory it would be fine for a multi-user system that practically only has one user.
That's most of my use-cases anyhow.
It looks like the context of the link is interfering with pathing and it catches it breaking hermeticity.

```Bash
sudo ln -s $(realpath flake.nix) $(realpath configuration.nix) /etc/nixos/
  error: 'flake.nix' file of flake 'path:/etc/nixos?lastModified=1672461843&narHash=sha256-lwXGTor+un0g9zRXt73NcNHW9SEkLhy1Y4l0nKTDhLM=' escapes from '/nix/store/v0siba5pd9gxqhxlnmmhha4v3dsy0gxr-source'
```

Sometimes for WSL, it won't match config on hostname for initial setup.
Run `sudo hostname bruce-banner` to temporarily adjust the host name.
It will now match and from there on Nix will manage it.
If installing directly from GitHub just use the # qualifier and it should be good.

## References

- [VSCode server workaround](https://github.com/msteen/nixos-vscode-server)
- [Opinionated flake structure](https://github.com/snowfallorg/lib)
- [Home-manager configuration options](https://nix-community.github.io/home-manager/options.html)
- [Misterio77's starter configs](https://github.com/Misterio77/nix-starter-configs)

## WSL/SystemD Errors

https://github.com/nix-community/NixOS-WSL/issues/185
