{
  config,
  lib,
  ...
}: {
  imports = [./garage.nix ./caddy.nix ./nix-serve.nix ./monitoring.nix];
  options.control-node = {
    enable = lib.options.mkOption {
      description = ''
        Whether this is a controller
      '';
      default = false;
      type = lib.types.bool;
    };
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
      "ip saddr { 192.168.1.0/24,192.168.2.0/24 } tcp dport 80 accept comment \"Allow private IPv4 HTTP\""
      "ip6 saddr { 2403:580a:e4b1::/48 } tcp dport 80 accept comment \"Allow my IPv6 prefix\""
      "ip6 saddr { fe80::/10 } tcp dport 80 accept comment \"Allow link-local HTTP\""
    ];
  };
}
