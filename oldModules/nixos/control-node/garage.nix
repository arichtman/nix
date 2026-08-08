{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.control-node.enable {
    services = {
      garage = {
        enable = true;
        environmentFile = "/var/lib/garage/.env";
        settings = {
          replication_factor = 1;
          rpc_bind_addr = "[::]:3901";
          s3_api = {
            api_bind_addr = "[::]:3900";
            s3_region = "garage";
          };
          s3_web = {
            bind_addr = "[::]:3902";
            root_domain = ".garage.${config.control-node.serviceDomain}";
          };
          admin = {
            api_bind_addr = "[::]:3903";
          };
        };
        package = pkgs.garage;
      };
      caddy = {
        virtualHosts = {
          "garage.${config.control-node.serviceDomain}:80" = {
            extraConfig = ''
              handle_path /garage* {
                reverse_proxy localhost:3900
              }
            '';
          };
          "web-garage.${config.control-node.serviceDomain}:80" = {
            extraConfig = ''
              handle_path /garage/web* {
                reverse_proxy localhost:3902
              }
            '';
          };
          "admin-garage.${config.control-node.serviceDomain}:80" = {
            extraConfig = ''
              handle_path /garage/admin* {
                reverse_proxy localhost:3903
              }
            '';
          };
        };
      };
      prometheus.scrapeConfigs = [(lib.arichtman.mkLocalScrapeConfig "garage" 3903)];
    };
  };
}
