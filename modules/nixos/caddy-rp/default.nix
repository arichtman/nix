{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.caddyRP;
in {
  options.services.caddyRP.enabled = lib.options.mkOption {
    type = lib.types.bool;
    default = false;
  };
  config = lib.mkIf cfg.enabled {
    networking.firewall.extraInputRules = lib.concatStringsSep "\n" [
      # Allow anything IPv6 into HTTP
      # Required for ACME HTTP challenge
      # "ip6 saddr { ::/0 } tcp dport 80 accept"
      # Allow anything IPv6 into HTTPS
      # "ip6 saddr { ::/0 } tcp dport 443 accept"
      # Allow my IPv4 private subnets into HTTP
      "ip saddr { 192.168.1.0/24,192.168.2.0/24 } tcp dport 80 accept"
      # Allow anything in my primary prefix into HTTP
      "ip6 saddr { 2403:580a:e4b1::/48 } tcp dport 80 accept"
    ];
    services = {
      caddy = {
        enable = true;
        # For testing
        acmeCA = "https://acme-staging-v02.api.letsencrypt.org/directory";
        email = "ariel@richtman.au";
        globalConfig = lib.concatStringsSep "\n" [
          # Don't store out-of-band config changes
          "persist_config off"
          # As advised for auto-reload to not wait forever
          "grace_period 10s"
          # Enable for Prometheus
          "servers { metrics }"
          # Disable TLS as we're internal
          "auto_https off"
          # For testing
          "debug"
          # Doesn't work without an actual IP I think...
          # Set to IPv6 so it doesn't try IPv4 ACME and bomb
          # "default_bind ip6/[::]"
          # Ref: https://caddy.community/t/bind-caddy-to-ipv6-only-via-docker-compose/22988/6
        ];
        virtualHosts = {
          # Maybe try `reverse_proxy` directive
          # and look into response rewrite to see about the /graph issue
          "http://home.richtman.au" = {
            extraConfig = ''
              redir /graph /prometheus/graph
              handle_path /prometheus* {
                reverse_proxy localhost:9090
              }
            '';
          };
        };
      };
    };
  };
}
