{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.control-node.enable {
    services = {
      step-ca = {
        # enable = true;
        # address = "::1";
        port = 7443;
        intermediatePasswordFile = "";
      };
    };
    networking.firewall.extraInputRules = lib.concatStringsSep "\n" [
      "ip6 saddr { ${lib.arichtman.net.ip6.prefixCIDR} } tcp dport 7443 accept comment \"Allow HTTPS for CA\""
    ];
  };
}
