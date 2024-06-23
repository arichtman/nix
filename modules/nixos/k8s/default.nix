{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: let
  k8l = import ./lib.nix;
in {
  imports = [./kubelet.nix ./apiserver.nix];
  options.services.k8s = {
    controller = lib.options.mkOption {
      description = ''
        Whether this is a controller
      '';
      default = false;
      type = lib.types.bool;
    };
  };
  options.services.k8s-apiserver.config = lib.mkIf config.services.k8s.controller [
    {
      foo = "bar";
    }
  ];
}
