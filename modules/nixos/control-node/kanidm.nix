{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.control-node.enable {
    services = {
      kanidm = {
        enableServer = true;
        # enablePam = true;
        unixSettings = {
          pam_allowed_login_groups = ["all_access"];
        };
        enableClient = true;
        package = pkgs.kanidm_1_8;
        server.settings = {
          origin = "https://${config.services.kanidm.serverSettings.domain}";
          domain = "id.richtman.au";
          bindaddress = "[::]:8443";
          ldapbindaddress = "[::]:3636";
          http_client_address_info = {
            x-forward-for = [lib.arichtman.net.ip6.subnet lib.arichtman.net.ip4.subnet];
          };
          tls_chain = "/var/lib/kanidm/cert.pem";
          tls_key = "/var/lib/kanidm/key.pem";
        };

        clientSettings = {
          uri = config.services.kanidm.serverSettings.domain;
        };
        # TODO: Was causing service startup failures, 403 denial on attempting to modify this user, specifically legal name.
        # I think it's to do with idm_admin not being allowed to modify certain fields?
        provision = {
          enable = false;
          persons = {
            arichtman = {
              mailAddresses = ["ariel@richtman.au"];
              legalName = "Richtman, Ariel";
              displayName = "Ariel";
            };
          };
        };
      };
      restic.backups.kanidm = {
        initialize = true;
        user = "kanidm";
        backupPrepareCommand = "${config.services.kanidm.package}/bin/kanidmd database backup ${config.services.kanidm.serverSettings.online_backup.path}/kanidm.backup.json";
        backupCleanupCommand = "rm -fr ${config.services.kanidm.serverSettings.online_backup.path}/kanidm.backup.json";
        paths = [
          "${config.services.kanidm.serverSettings.online_backup.path}/kanidm.backup.json"
        ];
        environmentFile = "/var/lib/restic/s3-servers-australia";
        extraBackupArgs = [
          "--tag kanidm"
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
      "ip6 saddr { ${lib.arichtman.net.ip6.prefixCIDR} } tcp dport 8443 accept comment \"Allow HTTPS for auth\""
      "ip6 saddr { ${lib.arichtman.net.ip6.prefixCIDR} } tcp dport 3636 accept comment \"Allow LDAP\""
    ];
    # Ref: https://git.dblsaiko.net/systems/tree/configurations/vineta/kanidm.nix
    systemd.services.kanidm = {
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
