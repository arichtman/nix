{
  config,
  lib,
  ...
}: {
  imports = [
    ./caddy.nix
    ./kanidm.nix
    ./garage.nix
    ./iocaine.nix
    ./forgejo.nix
    ./loki.nix
    ./prometheus.nix
    ./nix-serve.nix
    ./monitoring.nix
    ./restic.nix
    ./step-ca.nix
    ./tempo.nix
    ./website.nix
  ];
  options.control-node = {
    enable = lib.mkEnableOption "Whether this is a controller";
    serviceDomain = lib.options.mkOption {
      description = "FQDN of services";
      default = "services.richtman.au";
      type = lib.types.str;
    };
  };
  config = lib.mkIf config.control-node.enable {
    networking.firewall.extraInputRules = lib.concatStringsSep "\n" [
      # Allow anything IPv6 into HTTP
      # Required for ACME HTTP challenge
      # "ip6 saddr { ::/0 } tcp dport 80 accept"
      # Allow anything IPv6 into HTTPS
      # "ip6 saddr { ::/0 } tcp dport 443 accept"
      "ip saddr { ${lib.arichtman.net.ip4.subnet} } tcp dport 80 accept comment \"Allow private IPv4 HTTP\""
      "ip6 saddr { ${lib.arichtman.net.ip6.prefixCIDR} } tcp dport 80 accept comment \"Allow my IPv6 prefix\""
      "ip6 saddr { fe80::/10 } tcp dport 80 accept comment \"Allow link-local HTTP\""
    ];
  };
}
