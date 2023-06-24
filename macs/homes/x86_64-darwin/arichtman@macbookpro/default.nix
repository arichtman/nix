{ lib, pkgs, config, ... }:
let
  myShellAliases = {
    "brute-force-darwin-rebuild-switch" =  "until darwin-rebuild switch --flake . ; do : ; done";
  };
in
{
  #TODO: This not applying?
  snowfallorg.user.arichtman.home.config.home.file."_homes_x86_64-darwin_arichtman@macbookpro_default.nix".text = "";
  home = {
    stateVersion = "22.11";
    #TODO: Why is this not taking effect...
    # I think it's going to bashrc and not zshrc
    # But the docs say it should be for all shells...
    shellAliases = myShellAliases;
    file."_homes_x86_64-darwin_arichtman@macbookpro_default.nix".text = "";
    #TODO claims home.programs doesn't exist
    # programs.zsh.shellAliases = myShellAliases;
    # Also fails
    # config.programs.zsh.enable = true;
  };
  config.programs.zsh.shellAliases = myShellAliases;
  home-manager = {
    #TODO claims home-manager.users.arichtman.home-manager doesn't exist
    programs.zsh.shellAliases = myShellAliases;
  };
}
