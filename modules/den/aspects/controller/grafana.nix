{
  den.aspects.controller.grafana = {
    nixos = {
      config,
      lib,
      host,
      ...
    }:
    # TODO: Pull out somewhere into another file or something
    let
      alertManager = host.fetchGrafanaDashboard {
        id = 9578;
        revision = 4;
        name = "AlertManager";
        hash = "sha256:16jvazvjswiyn281z4r7wmwb18841d3ar24951538kma28l05izy";
      };
      cardinalityExplorer = host.fetchGrafanaDashboard {
        id = 11304;
        revision = 1;
        name = "Cardinality_Explorer";
      };
      etcdClusterOverview = host.fetchGrafanaDashboard {
        id = 21473;
        revision = 3;
        name = "Etcd_Cluster_Overview";
      };
      goMetrics = host.fetchGrafanaDashboard {
        id = 10826;
        revision = 2;
        name = "Go_Metrics";
      };
      goProcesses = host.fetchGrafanaDashboard {
        id = 6671;
        revision = 2;
        name = "Go_Processes";
      };
      grafanaInternals = host.fetchGrafanaDashboard {
        id = 3590;
        revision = 3;
        name = "Grafana_Internals";
      };
      k8sApiServer = host.fetchGrafanaDashboard {
        id = 12006;
        revision = 1;
        name = "Kubernetes_ApiServer";
      };
      nodeExporter = host.fetchGrafanaDashboard {
        id = 1860;
        revision = 42;
        name = "Node_Exporter_Full";
      };
      otelTempo = host.fetchGrafanaDashboard {
        id = 23242;
        revision = 1;
        name = "Opentelemetry_&_Tempo";
      };
      prom2 = host.fetchGrafanaDashboard {
        id = 3662;
        revision = 2;
        name = "Prometheus_2.0";
      };
      promMetricsManagement = host.fetchGrafanaDashboard {
        id = 19341;
        revision = 4;
        name = "Prometheus_Metrics_Management";
      };
      proxmoxViaPrometheus = host.fetchGrafanaDashboard {
        id = 10347;
        revision = 5;
        name = "Proxmox_via_Prometheus";
        hash = "sha256:1zwfhp312yxv5jm1js6vsnd46f5ph0np86c47dbdc3xg3d9m4yxc";
      };
    in {
      # Not working, suspect tmpfs created for pod is permissions-wise out of reach of node exporter
      # Ref: https://github.com/prometheus/node_exporter/issues/2470#issuecomment-1247604030
      systemd.services.prometheus-node-exporter.serviceConfig = {
        ProtectHome = lib.mkForce "read-only";
      };
      services = {
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
              root_url = "https://grafana.${host.net.serviceDomain}/";
            };
            security = {
              secret_key = "$__file{/var/lib/grafana/secrets/secret_key}";
            };
          };
          provision = {
            enable = true;
            # dashboards.settings.providers = [
            # {
            # Not working: error watching folder: %w
            # looks like a golang goof that I can't see the path
            # orgId = 1;
            # options.path = ./dashboards;
            # options.path = pkgs.stdenv.mkDerivation {
            # name = "grafana-dashboards";
            # src = ./grafana-dashboards;
            # installPhase = ''
            #     mkdir -p $out/
            #     install -D -m755 $src/*.json $out/
            #   '';
            # };
            # options.path = alertManager;
            # path = testDashboard;
            # name = "ZZZZZ";
            # options.path = "/var/lib/grafana/dashboards";
            # }
            # ];
          };
        };
        prometheus.scrapeConfigs = [
          (host.mkLocalScrapeConfig "grafana" config.services.grafana.settings.server.http_port)
        ];
      };
    };
  };
}
