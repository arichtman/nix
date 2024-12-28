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
        virtualHosts = {
          ":5000" = {
            # We have to bind to tcp6 specifically else it tries to do dual stack
            #  which clashes with nix-serve already on 5000 @ v4
            extraConfig = ''
              bind tcp6/[::]
              handle_path /* {
                reverse_proxy 127.0.0.1:5000
              }
            '';
          };
        };
      };
    };
  };
}
