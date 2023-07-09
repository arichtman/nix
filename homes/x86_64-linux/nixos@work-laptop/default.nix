{
  lib,
  pkgs,
  config,
  ...
}: {
  default-home = {
    username = "nixos";
    git = {
      email = "Ariel.Richtman@SilverRailTech.com";
      username = "Ariel Richtman";
    };
  };
}
