{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.control-node.enable {
    services = {
      nix-serve = {
        enable = true;
        openFirewall = true;
        secretKeyFile = "/var/lib/nix-serve/cache-private-key.pem";
      };
      # Required to enable IPv6 for nix-serve the binary cache
      caddy = {
        enable = true;
        email = "ariel@richtman.au";
        globalConfig = lib.concatStringsSep "\n" [
          # Don't store out-of-band config changes
          "persist_config off"
          # As advised for auto-reload to not wait forever
          "grace_period 10s"
          # Enable for Prometheus
          "metrics"
          # Disable TLS as we're internal
          "auto_https off"
          # For testing
          # "debug"
        ];
        # TODO: Should wire the port number in properly but it means assuming iocaine with Caddy...
        extraConfig = ''
          (iocaine) {
            @read method GET HEAD
            reverse_proxy @read [::1]:42069 {
              @fallback status 421
              handle_response @fallback
            }
          }
        '';
        # Set default response to error so invalid/unrouted requests are obvious
        # Ref: https://caddy.community/t/why-caddy-emits-empty-200-ok-responses-by-default/17634
        virtualHosts = {
          ":80" = {
            extraConfig = ''
              respond "No upstream configured" 204 {
                close
              }
            '';
          };
        };
      };
      prometheus.scrapeConfigs = [(lib.arichtman.mkLocalScrapeConfig "caddy" 2019)];
    };
  };
}
