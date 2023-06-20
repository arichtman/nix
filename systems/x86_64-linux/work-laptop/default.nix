{
  lib,
  pkgs,
  ...
}:
with lib; {
  networking.hostName = "work-laptop";
  #TODO
  snowfallorg.user.arichtman.home.config.home.file."_systems.x86_64-linux_work-laptop_default.nix".text = "";

  arichtman.wsl.enable = true;
  arichtman.default-home = {
    username = "nixos";
    git.email = "ariel.richtman@silverrailtech.com";
    git.username = "Richtman, Ariel";
  };
  arichtman.work-home.enabled = true;

}
