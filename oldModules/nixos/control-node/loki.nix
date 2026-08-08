{
  config,
  lib,
  ...
}: {
  config.services = lib.mkIf config.control-node.enable {
    loki = {
      enable = false;
      configuration = {
      };
    };
  };
}
