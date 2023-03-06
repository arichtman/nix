#!/usr/bin/env zsh
# Setup script for Mac

# Update the system
softwareupdate --install --all

# Install nix
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# Pickup changes so we can use nix commands
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

# Whatever workaround

printf 'run\tprivate/var/run\n' | sudo tee -a /etc/synthetic.conf
sudo /System/Library/Filesystems/apfs.fs/Contents/Resources/apfs.util -t

# Install nix-darwin

nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A installer
# Accept the option to manage nix-darwin using nix-channel or else it bombs
sudo ./result/bin/darwin-installer

#region workarounds

# PATH is still borked so system "git" keeps running, prompting xcode-tools install
nix shell nixpkgs#git

# Until this is addressed https://github.com/LnL7/nix-darwin/issues/149
sudo mv /etc/nix/nix.conf /etc/nix/.nix-darwin.bkp.nix.conf

# nix-darwin will whinge if this exists
#  but the file n-d generates doesn't source the daemon stuff
#  however it does source (if exists) a .local variant
sudo mv /etc/zshenv /etc/zshenv.local

#endregion

# Optional, but recommended
nix flake update

#region Bootstrap
# this has to be run once to install nix-darwin and configure stuff
#  afterwards can run darwin-rebuild switch --flake . directly

nix build .#darwinConfigurations.macbookpro.system

./result/sw/bin/darwin-rebuild switch --flake .#macbookpro

#endregion

