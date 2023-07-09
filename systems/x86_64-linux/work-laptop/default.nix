{
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  networking.hostName = "work-laptop";
  wsl-system.enable = true;
}
