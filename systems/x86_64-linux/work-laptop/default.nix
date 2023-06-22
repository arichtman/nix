{
  lib,
  pkgs,
  ...
}:
with lib; {
  networking.hostName = "work-laptop";

  #TODO: move to mac only
  services.yubikey-agent.enable = true;

  snowfallorg.user.arichtman.home.config = {
    default-home = {
      username = "nixos";
      git.email = "Ariel.Richtman@SilverRailTech.com";
      git.username = "Ariel Richtman";
    };
    #TODO: remove after development
    file."_systems.x86_64-linux_work-laptop_default.nix".text = "";
    # isNormalUser = true;
    # wsl-system.enable = true;
  };
}
