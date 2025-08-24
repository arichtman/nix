{
  config,
  lib,
  ...
}: {
  # Not working, suspect tmpfs created for pod is permissions-wise out of reach of node exporter
  # Ref: https://github.com/prometheus/node_exporter/issues/2470#issuecomment-1247604030
  config.systemd.services.prometheus-node-exporter.serviceConfig = lib.mkIf config.control-node.enable {
    ProtectHome = lib.mkForce "read-only";
  };
  config.services = lib.mkIf config.control-node.enable {
    caddy = {
      enable = true;
      virtualHosts = {
        "grafana.services.richtman.au:80" = {
          extraConfig = ''
            handle_path /grafana* {
              reverse_proxy localhost:${toString config.services.grafana.settings.server.http_port}
            }
          '';
        };
      };
    };
    grafana = {
      enable = true;
      settings = {
        server = {
          # Note: This must be set for Oauth to work, otherwise the redirect URL is insecure and localhost on port 3000
          root_url = "https://grafana.${config.control-node.serviceDomain}/";
        };
      };
      provision = {
        enable = true;
      };
    };
  };
}
