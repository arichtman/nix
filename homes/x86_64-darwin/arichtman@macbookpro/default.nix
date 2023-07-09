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
  default-home = {
    username = "arichtman";

    git = {
      email = "10679234+arichtman@users.noreply.github.com";
      username = "Richtman, Ariel";
    };
  };
  home = {
    shellAliases = myShellAliases;
  };
}
