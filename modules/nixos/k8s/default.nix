{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [./etcd.nix ./apiserver.nix];
  options.services.k8s = {
    controller = lib.options.mkOption {
      description = ''
        Whether this is a controller
      '';
      default = false;
      type = lib.types.bool;
    };
    # TODO: Should this be a config option? I only really wanted it consistent/DRY
    secretsPath = lib.options.mkOption {
      description = "Path to secrets";
      default = "/var/lib/kubernetes/secrets";
      type = lib.types.path;
    };
  };
  # TODO: Review or remove these. they're just for development
  config.environment.systemPackages = [pkgs.ripgrep pkgs.kubernetes];
  config.services.k8s-apiserver.config = lib.mkIf config.services.k8s.controller [
    {
      foo = "bar";
    }
  ];
}
