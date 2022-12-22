# Work configurations

1. Apply `configuration.nix`
1. *As nixos user* run
   `systemctl --user enable auto-fix-vscode-server.service`
   `systemctl --user start auto-fix-vscode-server.service`
1. Voila

## Flake use

Currently heavily WIP

`nix develop .` should net you a shell with terragrunt.

`nixos-rebuild build --flake .#ec2` can test the flake build
`nix develop .#imported` can test the dev shell

TODO: look at buildEnv instead of devShell
