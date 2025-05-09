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
      # bind_port = "";
      # ca_key_type = "";
      ca_subject = [
        {
          country = ["AU"];
          organization = ["Richtman"];
          common_name = "Spire";
        }
      ];
      # ca_ttl = "5m";
      data_dir = "./.data";
      jwt_issuer = "spire.services.richtman.au";
      # TODO: get a writable directory for logs, maybe systemd tmpDir
      log_file = "/tmp/spire-server.log";
      # log_file = "/var/log/spire-server.log";
      log_level = "debug";
      # agent_ttl = "5m";
      default_x509_svid_ttl = "5m";
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
              connection_string = "./.data/datastore.sqlite3";
            };
          };
        }
      ];
      KeyManager = [
        {
          disk = {
            plugin_data = {
              keys_path = "./.data/keys.json";
            };
          };
        }
      ];
      # "KeyManager \"memory\"" = {
      #   plugin_data = {};
      # };
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
    users = {
      users = {
        spire-server = {
          # TODO: See about using DynamicUser and StateDirectory
          description = "Spire server user";
          # TODO: See about automatic group creation
          group = "spire";
          home = "/var/lib/spire";
          createHome = true; # TODO: make this a systemd tmpfile like etcd's dir?
          homeMode = "755";
          isSystemUser = true;
        };
      };
      # Required to create the kubernetes group
      groups.spire = {};
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
        # ExecStart = "${pkgs.spire-server}/bin/spire-server run " + "-config " + checkedConfigFile + " -logLevel debug";
        ExecStart = "${pkgs.spire-server}/bin/spire-server run " + "-config " + checkedConfigFile;
        WorkingDirectory = "/var/lib/spire";
        # TODO: not sure if there's any nicer way to couple these to the user definition
        User = "spire-server";
        Group = "spire";
        # AmbientCapabilities = "cap_net_bind_service";
        Restart = "on-failure";
        RestartSec = 5;
      };
      unitConfig = {
        StartLimitIntervalSec = 0;
      };
    };
  };
}
