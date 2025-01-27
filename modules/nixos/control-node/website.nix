{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.control-node.enable {
    services = {
      caddy = {
        virtualHosts = {
          "www.${config.control-node.serviceDomain}:80" = {
            extraConfig = ''
              handle_path /www* {
                root * /var/lib/caddy/www
                file_server
              }
            '';
          };
        };
      };
    };
  };
}
