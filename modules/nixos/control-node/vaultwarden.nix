{
  config,
  lib,
  pkgs,
  ...
}: let
  address = "pw.richtman.au";
  secretsDir = "/var/lib/vaultwarden/secrets";
in {
  config = lib.mkIf config.control-node.enable {
    systemd.tmpfiles = {
      # Required for secret subdirectory
      settings.vaultwarden."${secretsDir}" = {
        d = {
          user = "root";
          group = "vaultwarden";
          mode = "0550";
        };
      };
    };
    services = {
      vaultwarden = {
        enable = true;
        domain = address;
        config = {
          # Ref: https://github.com/dani-garcia/vaultwarden/wiki/Configuration-overview
          SSO_ENABLED = true;
          SSO_ONLY = true;
          SSO_AUTHORITY = "${config.services.kanidm.server.settings.origin}/oauth2/openid/vaultwarden";
          SSO_CLIENT_ID = "vaultwarden";
          SSO_CLIENT_SECRET_FILE = "${secretsDir}/oidc_client_secret";
          ADMIN_TOKEN_FILE = "${secretsDir}/admin_token_hash";
          DNS_PREFER_IPV6 = true;
          ROCKET_ADDRESS = "::";
        };
      };
      restic.backups.vaultwarden = let
        vwPath = "/var/lib/vaultwarden";
        backupPath = "${vwPath}/db.sqlite3.backup";
      in {
        initialize = true;
        user = "vaultwarden";
        # No stdout backup AFAICT, /proc/$$/fd/1 doesn't work either
        backupPrepareCommand = ''${lib.getExe pkgs.sqlite} ${vwPath}/db.sqlite3 ".backup ${backupPath}" '';
        backupCleanupCommand = "rm -fr ${backupPath}";
        # Ref: https://github.com/dani-garcia/vaultwarden/wiki/Backing-up-your-vault
        paths = [
          backupPath
          "${vwPath}/attachments"
          "${vwPath}/sends"
          "${vwPath}/config.json"
          "${vwPath}/rsa_key.pem"
        ];
        environmentFile = "/var/lib/restic/s3-servers-australia";
        extraBackupArgs = [
          "--tag vaultwarden"
          "--tag subsoil"
        ];
        timerConfig = {
          OnCalendar = "15:00";
          Persistent = true;
          RandomizedDelaySec = "15m";
        };
        repository = "s3:https://s3.si.servercontrol.com.au/backups";
      };
    };
    networking.firewall.extraInputRules = lib.concatStringsSep "\n" [
      "ip6 saddr { ${lib.arichtman.net.ip6.prefixCIDR} } tcp dport 8000 accept comment \"Allow HTTP for Vaultwarden\""
    ];
  };
}
