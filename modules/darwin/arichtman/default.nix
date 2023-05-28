{ options, config, lib, pkgs, ... }:
let
  cfg = config.arichtman.darwin;
in
#TODO: Revisit the use of lib
with lib;
# with lib.internal;
{
  options.arichtman.darwin = {
    enable = lib.mkEnableOption "Apply darwin configuration.";
  };
  config = mkIf cfg.enable {
    nix.settings.trusted-users = [
      "@admin"
    ];
  };
}