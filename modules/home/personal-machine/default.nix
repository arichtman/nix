{
  config,
  lib,
  ...
}: let
  cfg = config.personal-machine;
in
  with lib; {
    options.personal-machine.enabled = lib.mkEnableOption "Configure as a personal use machine";
    config = mkIf cfg.enabled {
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        matchBlocks = {
          "*" = {};
          "proxmox.*" = {
            user = "root";
          };
          "opnsense.*" = {
            user = "root";
          };
          "*.local" = {
            user = "nixos";
          };
          "*.systems.richtman.au" = {
            user = "nixos";
          };
          github = {
            hostname = "github.com";
            user = "git";
          };
          probics = {
            user = "User";
            hostname = "probics.ddns.net";
            identityFile = "~/.ssh/probics-home";
            port = 2222;
            localForwards = [
              {
                bind.address = "";
                bind.port = 5000;
                host.address = "localhost";
                host.port = 3389;
              }
            ];
          };
          ap = {
            user = "chanya";
            hostname = "ap.internal";
          };
          os = {
            hostname = "opnsense.internal";
          };
          pm = {
            hostname = "proxmox.internal";
          };
          # All the user repetition is dumb but it wasn't hitting the "*.systems.richtman.au" match on my MBP
          fc = {
            hostname = "fat-controller.systems.richtman.au";
            user = "nixos";
          };
          pz = {
            hostname = "patient-zero.systems.richtman.au";
            user = "nixos";
          };
          ds = {
            hostname = "dr-singh.systems.richtman.au";
            user = "nixos";
          };
          sb = {
            hostname = "smol-bat.systems.richtman.au";
            user = "nixos";
          };
          tm = {
            hostname = "tweedledum.systems.richtman.au";
            user = "nixos";
          };
          te = {
            hostname = "tweedledee.systems.richtman.au";
            user = "nixos";
          };
        };
      };
    };
  }
