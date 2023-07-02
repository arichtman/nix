{
  lib,
  pkgs,
  config,
  ...
}: let
  myShellAliases = {
    "brute-force-darwin-rebuild-switch" = "until darwin-rebuild switch --flake . ; do : ; done";
    "brute-force-flake-update" = "until nix flake update --commit-lock-file ; do : ; done";
  };
in {
  home = {
    stateVersion = "22.11";
    shellAliases = myShellAliases;
    # TODO: remove after development
    file."_homes_x86_64-darwin_arichtman@macbookpro_default.nix".text = "";
  };
}
