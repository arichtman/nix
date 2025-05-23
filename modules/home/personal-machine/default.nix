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
      programs.ssh.enable = true;
      programs.ssh.matchBlocks = {
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
          hostname = "opnsense.local";
        };
        pm = {
          hostname = "proxmox.local";
        };
        fc = {
          hostname = "fat-controller.local";
        };
        pz = {
          hostname = "patient-zero.local";
        };
        ds = {
          hostname = "dr-singh.local";
        };
        sb = {
          hostname = "smol-bat.local";
        };
        tm = {
          hostname = "tweedledum.local";
        };
        te = {
          hostname = "tweedledee.local";
        };
      };
    };
  }
