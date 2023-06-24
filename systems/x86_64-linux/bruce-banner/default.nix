{
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  networking.hostName = "bruce-banner";
  arichtman.wsl-system.enabled = true;
  snowfallorg.user.arichtman.home.config = {
    default-home = {
      username = "nixos";
      git.email = "Ariel.Richtman@SilverRailTech.com";
      git.username = "Ariel Richtman";
    };
  };
}
