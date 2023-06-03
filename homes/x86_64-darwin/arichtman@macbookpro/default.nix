{ lib, pkgs, config, ... }:

{
  home = {
    stateVersion = "22.11";
    #TODO: Why is this not taking effect...
    # I think it's going to bashrc and not zshrc
    shellAliases = {
      "brute-force-darwin-rebuild-switch" =  "until darwin-rebuild switch --flake . ; do : ; done";
    };
    file.per-system-per-user-home.text = "working";
  };
}
