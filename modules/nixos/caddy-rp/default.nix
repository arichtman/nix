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
        ];
        virtualHosts = {
          # If hostname needs adjusting
          #     header_up Host {upstream_hostport}
          "http://fat-controller.local" = {
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
