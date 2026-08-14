{
  den.aspects.controller.forgejo = {
    nixos = {
      host,
      lib,
      config,
      ...
    }: rec {
      services = {
        forgejo = {
          enable = true;
          settings = {
            server = rec {
              # Required for front-end addresses not to break behind reverse proxies
              ROOT_URL = "https://${DOMAIN}:443";
              HTTP_ADDR = "::1";
              HTTP_PORT = 3001;
              DOMAIN = "forgejo.${host.net.serviceDomain}";
              # SSH_PORT = 222;
            };
            service = {
              # Ref: https://github.com/kanidm/kanidm/discussions/4045
              DISABLE_REGISTRATION = false;
              ALLOW_ONLY_EXTERNAL_REGISTRATION = true;
              # ENABLE_PASSWORD_SIGNIN_FORM = false;
              ENABLE_INTERNAL_SIGNIN = false;
              SHOW_REGISTRATION_BUTTON = false;
              ENABLE_BASIC_AUTHENTICATION = false;
            };
            openid = {
              ENABLE_OPENID_SIGNIN = false;
            };
            metrics = {
              ENABLED = true;
              ENABLED_ISSUE_BY_LABEL = true;
              ENABLED_ISSUE_BY_REPOSITORY = true;
            };
            oauth2_client = {
              OPENID_CONNECT_SCOPES = "email profile ssh_publickeys";
              # Strictly enumerated due to OIDC, TODO: remap on Kanidm side?
              # USERNAME = "displayname";
              ENABLE_AUTO_REGISTRATION = true;
              UPDATE_AVATAR = true;
              ACCOUNT_LINKING = "auto";
            };
          };
        };
        restic.backups.forgejo = {
          initialize = true;
          user = "forgejo";
          command = [
            (lib.getExe config.services.forgejo.package)
            "dump"
            "--config"
            "${config.services.forgejo.customDir}/conf/app.ini"
            "--file"
            "-"
          ];
          environmentFile = "/var/lib/restic/s3-servers-australia";
          extraBackupArgs = [
            "--tag forgejo"
            "--tag subsoil"
            "--stdin-filename ${config.services.forgejo.stateDir}/data/forgejo.db"
          ];
          timerConfig = {
            OnCalendar = "15:00";
            Persistent = true;
            RandomizedDelaySec = "15m";
          };
          repository = "s3:https://s3.si.servercontrol.com.au/backups";
        };
        caddy = {
          enable = true;
          virtualHosts = {
            "forgejo.services.richtman.au:80" = {
              extraConfig = ''
                handle_path /forgejo* {
                  reverse_proxy localhost:${toString services.forgejo.settings.server.HTTP_PORT}
                }
              '';
            };
          };
        };
        prometheus.scrapeConfigs = [(lib.arichtman.mkLocalScrapeConfig "forgejo" services.forgejo.settings.server.HTTP_PORT)];
      };
    };
  };
}
