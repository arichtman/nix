{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.control-node.enable {
    services = {
      step-ca = {
        enable = true;
        address = "[::]";
        port = 7443;
        intermediatePasswordFile = "/var/lib/step-ca/secrets/intermediate_password";
        settings = import ./step-ca/ca.nix {inherit config;};
      };
    };
    networking.firewall.extraInputRules = lib.concatStringsSep "\n" [
      "ip6 saddr { ${lib.arichtman.net.ip6.prefixCIDR} } tcp dport 7443 accept comment \"Allow HTTPS for CA\""
    ];
  };
}
