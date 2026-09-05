{
  den.aspects.controller.kanidm = {
    nixos = {
      host,
      pkgs,
      lib,
      ...
    }: let
      # Going to be string-interpolated anyways so no benefit for int
      kanidmPort = "8443";
    in rec {
      services = {
        kanidm = rec {
          # enablePam = true;
          unix.settings.kanidm = {
            pam_allowed_login_groups = ["all_access"];
          };
          client.enable = true;
          package = pkgs.kanidm_1_11;
          server.enable = true;
          server.settings = rec {
            origin = "https://${domain}";
            domain = "id.richtman.au";
            bindaddress = "[::]:${kanidmPort}";
            ldapbindaddress = "[::]:3636";
            http_client_address_info = {
              x-forward-for = [host.net.ip6.routerGlobalUnicastAddress];
            };
            # Export spans to Tempo
            # TODO: Figure out why it's not logging or CLI working locally with this on
            # otel_grpc_endpoint = "http://localhost:4317";
            tls_chain = "/var/lib/kanidm/cert.pem";
            tls_key = "/var/lib/kanidm/key.pem";
          };

          client.settings = {
            uri = server.settings.domain;
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
        prometheus.scrapeConfigs = [
          {
            job_name = "kanidm";
            metrics_path = "/probe";
            params = {
              module = ["http_2xx"];
              # Ref: https://github.com/kanidm/kanidm/issues/216
              target = ["https://localhost:${kanidmPort}/status"];
            };
            static_configs = [
              {
                # TODO: Wire in port directly?
                targets = ["localhost:${lib.toString 9115}"];
              }
            ];
          }
        ];
        restic.backups.kanidm = {
          initialize = true;
          user = "kanidm";
          backupPrepareCommand = "${services.kanidm.package}/bin/kanidmd database backup /var/lib/kanidm/backups/kanidm.backup.json";
          backupCleanupCommand = "rm -fr /var/lib/kanidm/backups/kanidm.backup.json";
          paths = [
            "/var/lib/kanidm/backups/kanidm.backup.json"
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
        "ip6 saddr { ${host.net.ip6.prefixCIDR} } tcp dport ${kanidmPort} accept comment \"Allow HTTPS for auth\""
        "ip6 saddr { ${host.net.ip6.prefixCIDR} } tcp dport 3636 accept comment \"Allow LDAP\""
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
  };
}
