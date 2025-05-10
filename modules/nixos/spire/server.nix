{
  lib,
  config,
  pkgs,
  ...
}: let
  topConfig = config.services.spire;
  cfg = config.services.spire-server;
  # Ref: https://github.com/NixOS/nixpkgs/blob/3566ab7246670a43abd2ffa913cc62dad9cdf7d5/nixos/modules/services/monitoring/prometheus/default.nix#L29C1-L38C20
  # a wrapper that verifies that the configuration is valid
  configCheck = file:
    pkgs.runCommand "spire-agent-config-checked" {
      preferLocalBuild = true;
      nativeBuildInputs = [pkgs.spire-server];
    } ''
      ln -s ${file} $out
      spire-server validate -config ${file} $out
    '';
  # Ref: https://github.com/spiffe/spire/blob/main/conf/server/server_full.conf
  serverConfig = {
    server = {
      admin_ids = ["spiffe://${topConfig.trustDomain}/admin"];
      bind_address = "[::1]";
      bind_port = topConfig.port;
      # ca_key_type = "";
      ca_subject = [
        {
          country = ["AU"];
          organization = ["Richtman"];
          common_name = "Spire";
        }
      ];
      # ca_ttl = "5m";
      # If this is not set in config file checks fail
      data_dir = "$STATE_DIRECTORY";
      # Can't use env var here as it fails checks
      # log_file = "$LOGS_DIRECTORY/server.log";
      jwt_issuer = "spire.services.richtman.au";
      log_level = "debug";
      # agent_ttl = "5m";
      # default_x509_svid_ttl = "5m";
      # default_jwt_svid_ttl = "5m";
      trust_domain = topConfig.trustDomain;
    };
    plugins = {
      CredentialComposer = [
        {
          uniqueid = {};
        }
      ];
      DataStore = [
        {
          sql = {
            plugin_data = {
              # TODO: Revisit this, postgres might be better uniformity
              #   though they may only support AWS options?
              database_type = "sqlite3";
              # Note: Does not default to data_dir or has weird interactions with DynamicUser/systemd exec context
              connection_string = "$STATE_DIRECTORY/datastore.sqlite3";
            };
          };
        }
      ];
      KeyManager = [
        {
          disk = {
            plugin_data = {
              keys_path = "$STATE_DIRECTORY/keys.json";
            };
          };
        }
      ];
    };
    telemetry = {
      Prometheus = {
        # Unsure what this defaults to
        # Ref: https://github.com/spiffe/spire/blob/v1.11.1/doc/telemetry/telemetry_config.md
        # host = "[::1]";
        port = 9988;
      };
    };
  };
  serverConfigFile = pkgs.writeText "spire-server-config" (builtins.toJSON serverConfig);
  checkedConfigFile = configCheck serverConfigFile;
in {
  options.services.spire-server.enable = lib.mkEnableOption "Enable Spire server";
  config = lib.mkIf cfg.enable {
    services.caddy.virtualHosts = {
      "spire.services.richtman.au:80" = {
        extraConfig = ''
          handle_path /spire* {
            reverse_proxy localhost:${toString topConfig.port}
          }
        '';
      };
    };
    systemd.services.spire-server = {
      description = "Spire server";
      # Required to activate the service.
      wantedBy = ["multi-user.target"];
      # Wait on networking.
      after = ["network.target"];
      serviceConfig = {
        # For managing resources of groups of services
        Slice = "spire.slice";
        ExecStart = lib.concatStringsSep " " [
          "${pkgs.spire-server}/bin/spire-server"
          "run"
          # Log directory is dynamic, so don't put it in config or the check fails
          "-logFile"
          "%L/spire/server.log"
          # TODO: find out why this env var isn't populated
          # Might be the execution context is pure sh or execv so no expansion
          # "$LOGS_DIRECTORY/server.log"
          # Required to use systemd dynamic user state dir
          "-expandEnv"
          "-config"
          checkedConfigFile
          "-logLevel"
          "debug"
        ];
        DynamicUser = true;
        Restart = "on-failure";
        RestartSec = 5;
        LogsDirectory = "spire";
        StateDirectory = "spire";
        # Required as default 0022 is considered too permissive
        UMask = "0027";
        # RuntimeDirectory = "spire";
        # TODO: Socket seems to be intended to be exposed.
        # This does not fix it, but entering the process mount namespace makes healthcheck pass
        # PrivateTmp = false;
      };
      unitConfig = {
        StartLimitIntervalSec = 5;
      };
    };
  };
}
