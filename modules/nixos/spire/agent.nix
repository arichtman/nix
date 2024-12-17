{
  lib,
  config,
  pkgs,
  ...
}: let
  topConfig = config.services.spire;
  cfg = config.services.spire-agent;
  # Ref: https://github.com/spiffe/spire/blob/main/conf/agent/agent_full.conf
  agentConfig = {
    server = {
      trust_domain = "";
      bind_address = "";
      bind_port = "";
    };
    telemetry = {
      Prometheus = {
        port = 9090;
      };
    };
  };
  agentConfigFile = pkgs.writeText "spire-agent-config" (builtins.toJSON agentConfig);
in {
  options.services.spire-agent = {
    enable = lib.options.mkOption {
      description = "Enable Spire agent";
      default = false;
      type = lib.types.bool;
    };
  };
  config =
    lib.mkIf cfg.enable {
    };
}
