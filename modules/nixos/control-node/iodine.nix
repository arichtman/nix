{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.control-node.enable {
    services.iodine = {
      server = {
        enable = true;
        domain = "d.richtman.au";
        passwordFile = "/var/lib/iodined/password.txt";
        ip = "10.255.254.1/24";
      };
    };
  };
}
