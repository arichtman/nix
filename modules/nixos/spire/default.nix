{
  config,
  lib,
  pkgs,
  ...
}: 
{
  imports = [./server.nix ./agent.nix];
  options.services.spire = {
    trustDomain = lib.options.mkOption {
      description = "Spire trust domain";
      default = "example.org";
      type = lib.types.str;
    };
    port = lib.options.mkOption {
      description = "Port for server to listen on";
      default = 8081;
      type = lib.types.int;
    };
  };
  config = {
  };
}
