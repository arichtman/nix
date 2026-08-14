{
  config,
  lib,
  ...
}: {
  imports = [
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
