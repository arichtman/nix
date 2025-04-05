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
  # # TODO: Reinstate after fixing cross-subnet IPv6
  # nix = {
  #   settings = {
  #     trusted-public-keys = lib.mkAfter ["fat-controller.systems.richtman.au:ULbki6cpX8A6Lvpx7XX7HuZ2qaEs0spWpvs+MOad204="];
  #     substituters = ["http://fat-controller.systems.richtman.au:5000"];
  #   };
  # };
  system.stateVersion = 4;
}
