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
      "ip6 saddr { ::/0 } tcp dport 80 accept"
      # Allow anything IPv6 into HTTPS
      "ip6 saddr { ::/0 } tcp dport 443 accept"
    ];
    services = {
      caddy = {
        enable = true;
        # For testing
        # acmeCA = "https://acme-staging-v02.api.letsencrypt.org/directory";
        email = "ariel@richtman.au";
        globalConfig = lib.concatStringsSep "\n" [
          # Don't store out-of-band config changes
          "persist_config off"
          # As advised for auto-reload to not wait forever
          "grace_period 10s"
          # Enable for Prometheus
          "servers { metrics }"
          # Doesn't work without an actual IP I think...
          # Set to IPv6 so it doesn't try IPv4 ACME and bomb
          # "default_bind ip6/[::]"
          # Ref: https://caddy.community/t/bind-caddy-to-ipv6-only-via-docker-compose/22988/6
        ];
        virtualHosts = {
          # the protocol portion controls TLS and the bind
          # not that we're using TLS but the hostname must match
          # this one's an upstream intended for access by nginx on opnsense
          "http://home.richtman.au" = {
            extraConfig = ''
              redir /graph /prometheus/graph
              redir /prometheus /prometheus/
              handle_path /prometheus/* {
                reverse_proxy localhost:9090
              }
            '';
          };
          "https://${config.services.r53-ddns.hostname}.${config.services.r53-ddns.domain}" = {
            # Requires DNS-01 challenge which needs compiled caddy
            # serverAliases = [ config.networking.fqdn "${config.networking.hostName}.internal" ];
            extraConfig = ''
              redir /graph /prometheus/graph
              redir /prometheus /prometheus/
              handle_path /prometheus/* {
                reverse_proxy localhost:9090
              }
            '';
          };
        };
      };
    };
  };
}
