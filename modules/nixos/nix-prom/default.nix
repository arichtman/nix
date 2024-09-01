{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.nginxProm;
in {
  options.services.nginxProm.enabled = lib.options.mkOption {
    type = lib.types.bool;
    default = false;
  };
  config = {
    services = lib.mkIf cfg.enabled {
      nginx = {
        enable = true;
        # this isn't behaving to send to syslog??
        # logError = "/tmp/nginx.log debug";
        logError = "stderr debug";
        upstreams = {
          prometheus = {
            servers = {
              "localhost:9090" = {};
            };
          };
        };
        # TODO: re-add. Noisy for examining config
        # recommendedProxySettings = true;
        # recommendedOptimisation = true;
        # recommendedGzipSettings = true;
        # recommendedBrotliSettings = true;
        # recommendedTlsSettings = true;
        # recommendedZstdSettings = true;
        # Note: this seems to prevent it from trying to serve static HTML/files from a directory
        defaultListen = [
          {
            addr = "0.0.0.0";
            proxyProtocol = true;
            ssl = true;
          }
          {
            addr = "[::0]";
            proxyProtocol = true;
            ssl = true;
          }
        ];
        virtualHosts = {
          "fat-controller.local" = {
            sslCertificate = "/var/nginx/ssl/nginx-ssl.pem";
            sslCertificateKey = "/var/nginx/ssl/nginx-ssl.key";
            # serverName = "";
            # onlySSL = true;
            forceSSL = true;
            locations = {
              "/prometheus/" = {
                proxyPass = "http://localhost:9090/";
                extraConfig = ''
                  rewrite  ^/prometheus(.*)$ $1 break;
                '';
                # This didn't fix it either
                # proxyPass = "http://127.0.0.1:9090";
              };
              # "/" = {
              #   # proxyPass = "http://prometheus$request_uri";
              #   # proxyPass = "http://prometheus/";
              #   proxyPass = "http://localhost:9090/";
              # };
              # alertManager = {
              #   proxyPass = "http://localhost:9093";
              # };
            };
          };
        };
      };
    };
  };
}
