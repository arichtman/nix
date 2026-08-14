{
  den.aspects.controller.step-ca = {
    nixos = {
      config,
      host,
      lib,
      ...
    }: {
      services = {
        step-ca = {
          enable = true;
          address = "[::]";
          port = 7443;
          intermediatePasswordFile = "/var/lib/step-ca/secrets/intermediate_password";
          settings = import ./_ca.nix {inherit config;};
        };
      };
      networking.firewall.extraInputRules = lib.concatStringsSep "\n" [
        "ip6 saddr { ${host.net.ip6.prefixCIDR} } tcp dport ${lib.toString config.services.step-ca.port} accept comment \"Allow HTTPS for CA\""
      ];
    };
  };
}
