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
        carapace.enable = true;
        carapace.enableNushellIntegration = true;
      };
      home = {
        file.".ssh" = {
          source = ./.ssh;
          recursive = true;
        };
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
          postman
          kubernetes-helm
          docker-client
        ];
      };
    };
  }
