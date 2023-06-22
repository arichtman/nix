{
  lib,
  pkgs,
  ...
}:
with lib; {
  networking.hostName = "work-laptop";

  services.yubikey-agent.enable = true;

  #TODO: remove after development
  snowfallorg.user.arichtman.home.config.home.file."_systems.x86_64-linux_work-laptop_default.nix".text = "";
  # arichtman.wsl.enable = true;
  # arichtman.default-home = {
  #   username = "nixos";
  #   git.email = "Ariel.Richtman@SilverRailTech.com";
  #   git.username = "Ariel Richtman";
  # };
  snowfallorg.user.arichtman.home.config = {
    default-home = {
      username = "nixos";
      git.email = "Ariel.Richtman@SilverRailTech.com";
      git.username = "Ariel Richtman";
    };
  };
  # snowfallorg.user.arichtman.wsl-system.enabled = true;
}
