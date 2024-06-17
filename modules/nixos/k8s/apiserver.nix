{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: let
  k8l = import ./lib.nix;
in {
  options.services.k8s-apiserver = {
    config = lib.options.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = [];
    };
  };
  environment.etc.cni.text = pkgs.writeText "baz" k8l.mkConfig config.services.k8s-apiserver.config;
}
