#!/usr/bin/env bash
# Setup script for Mac


# Update the system
softwareupdate —install —all

# Disable fancy graphics and dock
defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false
defaults write com.apple.Mail DisableReplyAnimations -bool YES
defaults write com.apple.Mail DisableSendAnimations -bool YES
defaults write com.apple.dock expose-animation-duration -int 0
defaults write com.apple.dock springboard-show-duration -int 0 defaults write com.apple.dock springboard-hide-duration -int 0
defaults write com.apple.dock no-bouncing -bool TRUE
killall Dock

# Update root certificates
curl -LkO https://curl.se/ca/cacert.pem
sudo ./trustroot cacert.pem 

# Change to new shell
chsh -s /bin/zsh

# Install nix and home-manager
sh <(curl -L https://nixos.org/nix/install) --daemon

nix-channel --add https://github.com/nix-community/home-manager/archive/release-22.11.tar.gz home-manager
nix-channel --update
export NIX_PATH=$HOME/.nix-defexpr/channels:/nix/var/nix/profiles/per-user/root/channels${NIX_PATH:+:$NIX_PATH}
nix-shell '<home-manager>' -A install

# Deploy our config and use
mkdir —parent $HOME/.config/nixpkgs
cp ./*.nix $HOME/.config/nixpkgs
cp —force ./nix.conf /etc/nix/

home-manager switch

