{
  config,
  lib,
  ...
}: {
  imports = [
    ./monitoring.nix
    ./restic.nix
    ./step-ca.nix
    ./tempo.nix
    ./vaultwarden.nix
    ./website.nix
  ];
  options.control-node = {
    enable = lib.mkEnableOption "Whether this is a controller";
    serviceDomain = lib.options.mkOption {
      description = "FQDN of services";
      default = "services.richtman.au";
      type = lib.types.str;
    };
  };
}
