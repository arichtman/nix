{
  options,
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  cfg = config.work-home;
  #TODO: Work this out when we switch to new lib
  # userName = config.snowfallorg.user.name;
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
        packages = with pkgs; [
          git-remote-codecommit
          teams
          mitmproxy
        ];
      };
    };
  }
