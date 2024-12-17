{
  config,
  lib,
  pkgs,
  ...
}: let
  foo = "";
in {
  imports = [./server.nix ./agent.nix];
  options.services.spire = {
    trustDomain = lib.options.mkOption {
      description = "Spire trust domain";
      default = "example.org";
      type = lib.types.str;
    };
  };
  config = {
  };
}
