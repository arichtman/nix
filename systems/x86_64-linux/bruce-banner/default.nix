{
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  networking.hostName = "bruce-banner";
  arichtman.wsl.enable = true;
  arichtman.default-home = {
    username = "nixos";
    git.email = "10679234+arichtman@users.noreply.github.com";
    git.username = "Richtman, Ariel";
  };
}
