{
  lib,
  pkgs,
  config,
  ...
}: {
  networking.hostName = "macbookpro";

  environment.systemPackages = with pkgs; [
    discord
    arduino-cli
    elf2nucleus
  ];
  system.stateVersion = 4;
}
