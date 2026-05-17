{
  config,
  lib,
  ...
}: let
  address = "pw.richtman.au";
in {
  config = lib.mkIf config.control-node.enable {
    systemd.tmpfiles = {
      settings.vaultwarden."/var/lib/vaultwarden/secrets" = {
        d = {
          user = "root";
          group = "vaultwarden";
          mode = "0640";
        };
      };
      # Free-texter approach
      rules = [
        # "d /var/local/vaultwarden 0755 vaultwarden vaultwarden -"
      ];
    };
    services = {
      vaultwarden = {
        enable = true;
        domain = "https://${address}";
        config = {
          # Ref: https://github.com/dani-garcia/vaultwarden/wiki/Configuration-overview
          # Ref: https://github.com/dani-garcia/vaultwarden/blob/1.36.0/.env.template
          SIGNUPS_ALLOWED = false;
          # SSO_ENABLED = true;
          # SSO_ONLY = true;
          # SSO_AUTHORITY = "${config.services.kanidm.server.settings.origin}/oauth2/openid/${config.services.vaultwarden.config.SSO_CLIENT_ID}";
          # SSO_CLIENT_ID = "vaultwarden";
          # SSO_CLIENT_SECRET_FILE = "/var/lib/vaultwarden/secrets/oidc_client_secret";
          # ADMIN_TOKEN = "$argon2id$v=19$m=65540,t=3,p=4$1VjoaV+tgBxhzAg23IxhopyfcVlN8dhLRROKnvVY0BI$wZYgZUHZIK/hZ6xsLajIqSL9eNA15kM3FKfGeaKJ110";
          # ADMIN_TOKEN_FILE = "";
          ROCKET_ADDRESS = "::";
          LOG_LEVEL = "debug";
        };
      };
    };
    networking.firewall.extraInputRules = lib.concatStringsSep "\n" [
      "ip6 saddr { ${lib.arichtman.net.ip6.prefixCIDR} } tcp dport 8000 accept comment \"Allow HTTP for Vaultwarden\""
    ];
  };
}
