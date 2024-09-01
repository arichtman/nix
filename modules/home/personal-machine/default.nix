{
  config,
  lib,
  ...
}: let
  cfg = config.personal-machine;
in
  with lib; {
    options.personal-machine = with types; {
      enabled = mkOption {
        type = bool;
        description = "Configure as a personal use machine";
        default = false;
      };
    };
    config = mkIf cfg.enabled {
      programs.ssh.enable = true;
      programs.ssh.matchBlocks = {
        proxmox = {
          hostname = "proxmox.internal";
          user = "root";
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
        "*.internal" = {
          user = "nixos";
        };
        "*.local" = {
          user = "nixos";
        };
        fc = {
          hostname = "fat-controller.local";
        };
        mum = {
          hostname = "mum.local";
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
