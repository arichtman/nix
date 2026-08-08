{
  lib,
  config,
  pkgs,
  ...
}: let
  topConfig = config.services.spire;
  cfg = config.services.spire-agent;
  # Ref: https://github.com/NixOS/nixpkgs/blob/3566ab7246670a43abd2ffa913cc62dad9cdf7d5/nixos/modules/services/monitoring/prometheus/default.nix#L29C1-L38C20
  # a wrapper that verifies that the configuration is valid
  configCheck = file:
    pkgs.runCommand "spire-agent-config-checked" {
      preferLocalBuild = true;
      nativeBuildInputs = [pkgs.spire-agent];
    } ''
      ln -s ${file} $out
      spire-agent validate -config ${file} $out
    '';
  # Ref: https://github.com/spiffe/spire/blob/main/conf/agent/agent_full.conf
  agentConfig = {
    agent = {
      trust_domain = topConfig.trustDomain;
      server_address = "${config.networking.hostName}.systems.richtman.au";
      # server_address = "spire.services.richtman.au";
      server_port = 8081;
      # Required until figure out trust bundle sourcing
      insecure_bootstrap = true;
      # Things might come up wonky
      retry_bootstrap = true;
      # trust_bundle_format = "spiffe";
      # trust_bundle_url = "https://${config.networking.hostName}.systems.richtman.au:8081";
    };
    # Ref: https://github.com/spiffe/spire/blob/v1.12.0/doc/telemetry/telemetry_config.md
    telemetry = {
      Prometheus = {
        # Required to avoid default IPv4-only binding
        host = "[::]";
        port = 9989;
      };
    };
    plugins = {
      KeyManager = [
        # TODO: It's erroring out on read-only FS trying to persist the SVID
        # {
        #   disk = {
        #     plugin_data = {
        #       # keys_path = "$STATE_DIRECTORY/keys.json";
        #       directory = "$STATE_DIRECTORY";
        #     };
        #   };
        # }
        {memory = {plugin_data = {};};}
      ];
      WorkloadAttestor = [{systemd = {plugin_data = {};};}];
      NodeAttestor = [{join_token = {plugin_data = {};};}];
      # NodeAttestor = [ { x509pop = { plugin_data = {
      #   private_key_path = "/var/lib/spire-agent/secrets/private_key";
      #  };};}];
      # NodeAttestor = [ { sshpop = { plugin_data = { };};}];
    };
  };
  agentConfigFile = pkgs.writeText "spire-agent-config" (builtins.toJSON agentConfig);
  checkedConfigFile = configCheck agentConfigFile;
in {
  options.services.spire-agent = {
    enable = lib.mkEnableOption "Enable Spire agent";
    joinToken = lib.options.mkOption {
      description = "Bootstrapping join token";
      type = lib.types.str;
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.services.spire-agent = {
      description = "Spire agent";
      # Required to activate the service.
      wantedBy = ["multi-user.target"];
      # Wait on networking.
      after = ["network.target"];
      serviceConfig = {
        # For managing resources of groups of services
        Slice = "spire.slice";
        ExecStart = lib.concatStringsSep " " [
          "${pkgs.spire-agent}/bin/spire-agent"
          "run"
          # No reason not to vend the trust bundles
          "-allowUnauthenticatedVerifiers"
          # Log directory is dynamic, so don't put it in config or the check fails
          "-logFile"
          "%L/spire-agent/agent.log"
          # Required to use systemd dynamic user state dir
          "-expandEnv"
          "-config"
          checkedConfigFile
          "-joinToken"
          config.services.spire-agent.joinToken
          # TODO: remove before flight
          "-logLevel"
          "debug"
        ];
        DynamicUser = true;
        Restart = "on-failure";
        RestartSec = 5;
        LogsDirectory = "spire-agent";
        StateDirectory = "spire-agent";
        # Required as default 0022 is considered too permissive
        UMask = "0027";
      };
    };
  };
  # TODO: Renable when agent is working
  # services.prometheus.scrapeConfigs = [(lib.arichtman.mkLocalScrapeConfig "spire-agent" 9989)];
}
