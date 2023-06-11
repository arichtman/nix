{ lib, pkgs, config, ... }:
let
  myShellAliases = {
    "brute-force-darwin-rebuild-switch" =  "until darwin-rebuild switch --flake . ; do : ; done";
  };
in
{
  config = {
    home = {
      stateVersion = "22.11";
      #TODO: Why is this not taking effect...
      # I think it's going to bashrc and not zshrc
      # But the docs say it should be for all shells...
      shellAliases = myShellAliases;
    };
    programs.zsh.shellAliases = myShellAliases;
  };
}
