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
      home = {
        file.".ssh" = {
          source = ./.ssh;
          recursive = true;
        };
        packages = with pkgs; [
          git-remote-codecommit
          teams
          k9s
          awscli2
          mitmproxy
          kubectl
        ];
      };
    };
  }
