{
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  networking.hostName = "bruce-banner";
  wsl-system.enable = true;
  wsl = {
    enable = true;
    wslConf.automount.root = "/mnt";
    defaultUser = "nixos";
    startMenuLaunchers = true;
    nativeSystemd = true;
  };
}
