{ options, config, pkgs, lib, inputs, ... }:
let
  cfg = config.arichtman.work-home;
  #TODO: Work this out when we switch to new lib
  # userName = config.snowfallorg.user.name;
in
with lib;
{
  options.arichtman.work-home = with types; {
    enabled = mkOption {
      type = bool;
      description = "Enable work home configuration";
    };
  };
    config = mkIf (cfg.enabled) {
      home-manager = {
        #TODO: Remove hard-coding
        users.nixos = {
          home = {
           packages = with pkgs; [
              git-remote-codecommit
            ];
          };
        };
      };
    };
}