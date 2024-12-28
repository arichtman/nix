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
          "servers { metrics }"
          # Disable TLS as we're internal
          "auto_https off"
          # For testing
          "debug"
        ];
      };
    };
  };
}
