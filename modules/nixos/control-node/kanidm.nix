{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.control-node.enable {
    # Ref: https://git.dblsaiko.net/systems/tree/configurations/vineta/kanidm.nix
    services = {
      kanidm = {
        enableServer = true;
        # enablePam = true;
        package = pkgs.kanidm_1_5;
        serverSettings = {
          origin = "https://${config.services.kanidm.serverSettings.domain}";
          domain = "id.richtman.au";
          bindaddress = "[::]:8443";
          ldapbindaddress = "[::]:3636";
          trust_x_forward_for = true;
          tls_chain = "/var/lib/kanidm/cert.pem";
          tls_key = "/var/lib/kanidm/key.pem";
        };

        clientSettings = {
          uri = config.services.kanidm.serverSettings.domain;
        };
      };
    };
    networking.firewall.extraInputRules = lib.concatStringsSep "\n" [
      "ip6 saddr { 2403:580a:e4b1::/48 } tcp dport 8443 accept comment \"Allow HTTPS for auth\""
      "ip6 saddr { 2403:580a:e4b1::/48 } tcp dport 3636 accept comment \"Allow LDAP\""
    ];
    systemd.services."kanidm" = {
      serviceConfig = {
        # move /var/lib/kanidm from RO to RW
        BindReadOnlyPaths = lib.mkForce [
          "/nix/store"
          "/run/systemd/notify"
          "-/etc/resolv.conf"
          "-/etc/nsswitch.conf"
          "-/etc/hosts"
          "-/etc/localtime"
        ];
        BindPaths = [
          "/var/lib/kanidm"
        ];
      };
    };
  };
}
