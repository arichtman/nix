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
            bb = {
              user = "ubuntu";
              hostname = "bamboo.silverrailtech.net";
              identityFile = "~/.ssh/AWS-DevTest.pem";
            };
          };
        };
      };
      home = {
        shellAliases."set-private-git-config" = "git config user.email '10679234+arichtman@users.noreply.github.com' ; git config user.name 'Ariel Richtman'";
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
