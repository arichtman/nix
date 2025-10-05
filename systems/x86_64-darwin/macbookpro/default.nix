{
  lib,
  pkgs,
  config,
  ...
}: {
  networking.hostName = "macbookpro";

  environment.systemPackages = [
    pkgs.colima
    pkgs.docker-client
  ];
  system.stateVersion = 4;
}
