{
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  networking.hostName = "bruce-banner";
  wsl-system.enable = true;
}
