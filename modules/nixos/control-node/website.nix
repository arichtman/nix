{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.control-node.enable {
    services.caddy = {
      enable = true;
      virtualHosts = {
        "www.richtman.au:80" = {
          extraConfig = ''
            handle_path /www* {
              import iocaine
              root * /var/lib/caddy/www
              file_server
            }
          '';
        };
      };
    };
  };
}
