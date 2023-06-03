{
  lib,
  pkgs,
  ...
}:
with lib; {
  networking.hostName = "work-laptop";
  arichtman.wsl.enable = true;
  arichtman.default-home = {
    username = "nixos";
    git.email = "ariel.richtman@silverrailtech.com";
    git.username = "Richtman, Ariel";
  };

}
