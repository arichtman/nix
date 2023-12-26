{
  options,
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.work-home;
in
  with lib; {
    options.work-home = with types; {
      enabled = mkOption {
        type = bool;
        description = "Enable work home configuration";
        default = false;
      };
    };
    config = mkIf (cfg.enabled) {
      programs = {
        nushell.enable = true;
        ssh = {
          enable = true;
          matchBlocks = {
            gl = {
              user = "ubuntu";
              hostname = "gitlab-bne.silverrail.io";
              identityFile = "~/.ssh/gitlab-prod";
            };
            vpn = {
              user = "ubuntu";
              hostname = "vpn-bne.silverrail.io";
              identityFile = "~/.ssh/openvpn";
            };
          };
        };
      };
      home = {
        packages = with pkgs; [
          git-remote-codecommit
          teams
          slack
          zoom-us
          k9s
          awscli2
          kubectl
          terraform
          terragrunt
          mitmproxy
          kubernetes-helm
          docker-client
        ];
      };
    };
  }
