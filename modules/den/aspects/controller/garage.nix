{
  den.aspects.controller.garage = {
    nixos = {
      host,
      pkgs,
      config,
      ...
    }: {
      services = {
        garage = {
          enable = true;
          environmentFile = "${config.services.garage.settings.metadata_dir}/.env";
          # GARAGE_RPC_SECRET=$(openssl rand -hex 32)
          # GARAGE_ADMIN_TOKEN=$(openssl rand -hex 32)
          settings = {
            replication_factor = 1;
            # TODO: set rpc_public_addr, as logs suggest
            rpc_bind_addr = "[::]:3901";
            s3_api = {
              api_bind_addr = "[::]:3900";
              s3_region = "garage";
            };
            s3_web = {
              bind_addr = "[::]:3902";
              root_domain = ".garage.${host.net.serviceDomain}";
            };
            admin = {
              api_bind_addr = "[::]:3903";
            };
          };
          # TODO: Upgrade to garage_2?
          package = pkgs.garage;
        };
        caddy = {
          virtualHosts = {
            "garage.${host.net.serviceDomain}:80" = {
              extraConfig = ''
                handle_path /garage* {
                  reverse_proxy localhost:3900
                }
              '';
            };
            "web-garage.${host.net.serviceDomain}:80" = {
              extraConfig = ''
                handle_path /garage/web* {
                  reverse_proxy localhost:3902
                }
              '';
            };
            "admin-garage.${host.net.serviceDomain}:80" = {
              extraConfig = ''
                handle_path /garage/admin* {
                  reverse_proxy localhost:3903
                }
              '';
            };
          };
        };
        prometheus.scrapeConfigs = [(host.mkLocalScrapeConfig "garage" 3903)];
      };
    };
  };
}
