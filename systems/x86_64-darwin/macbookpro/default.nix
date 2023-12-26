{
  lib,
  pkgs,
  config,
  ...
}: {
  networking.hostName = "macbookpro";

  environment.systemPackages = with pkgs; [
    discord
  ];
  system.stateVersion = 4;
}
