{
  den.aspects.controller.harmonia = {
    nixos = {
      lib,
      host,
      ...
    }: {
      services = {
        harmonia = {
          cache = {
            enable = true;
            signKeyPaths = ["/var/lib/harmonia/cache-private-key.pem"];
          };
          daemon = {
            enable = true;
          };
        };
        prometheus.scrapeConfigs = [
          (host.mkLocalScrapeConfig "harmonia" 5000)
        ];
      };
      networking.firewall.extraInputRules = lib.concatStringsSep "\n" [
        "ip6 saddr { ${host.net.ip6.prefixCIDR} } tcp dport 5000 accept comment \"Allow HTTP for Harmonia\""
      ];
    };
  };
  # Note: if the substituters cache breaks you may need to work around it
  # Ref: https://github.com/NixOS/nix/issues/8271#issuecomment-2870219149
}
