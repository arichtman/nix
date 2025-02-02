{
  config,
  lib,
  ...
}: let
  # Source: https://samber.github.io/awesome-prometheus-alerts/
  mkLocalScrapeConfig = name: port: {
    job_name = builtins.toString name;
    relabel_configs = promLocalHostRelabelConfigs;
    honor_labels = false;
    static_configs = [
      {
        targets = [
          "localhost:${builtins.toString port}"
        ];
        labels = {
          instance = "fat-controller.systems.richtman.au";
        };
      }
    ];
  };
  promLocalHostRelabelConfigs = [
    # TODO: Work out why localhost relabel and label override aren't working
    # Relabel localhost so we don't have to open metrics to the world
    {
      source_labels = ["__address__"];
      regex = ".*localhost.*";
      target_label = "instance";
      replacement = "fat-controller.systems.richtman.au";
    }
    # Remove port numbers
    {
      source_labels = ["__address__"];
      regex = "(.+):.*";
      target_label = "instance";
      replacement = "\${1}";
    }
  ];
in {
  # Not working, suspect tmpfs created for pod is permissions-wise out of reach of node exporter
  # Ref: https://github.com/prometheus/node_exporter/issues/2470#issuecomment-1247604030
  # config.systemd.services.prometheus-node-exporter.serviceConfig = lib.mkIf config.services.monitoring.enable {
  #   ProtectHome = lib.mkForce "read-only";
  # };
  config.services = lib.mkIf config.control-node.enable {
    kthxbye = {
      enable = true;
      port = 9099;
    };
    caddy = {
      enable = true;
      virtualHosts = {
        "prometheus.services.richtman.au:80" = {
          # TODO: Find out what fuckery is causing /prometheus/ to redirect to /graph
          # I tried setting Prom's web.external-url to the full thing with and without trailing slash.
          extraConfig = ''
            redir /graph /prometheus/graph
            handle_path /prometheus* {
              reverse_proxy localhost:9090
            }
          '';
        };
        "grafana.services.richtman.au:80" = {
          extraConfig = ''
            redir /login /grafana/login
            handle_path /grafana* {
              reverse_proxy localhost:3000
            }
          '';
        };
        "alertmanager.services.richtman.au:80" = {
          extraConfig = ''
            handle_path /alertmanager* {
              reverse_proxy localhost:9093
            }
          '';
        };
      };
    };
    grafana = {
      enable = true;
      settings = {};
      provision = {
        enable = true;
        datasources.settings.datasources = [
          {
            name = "prometheus";
            type = "prometheus";
            url = "http://localhost:9090";
            isDefault = true;
            editable = false;
          }
        ];
      };
    };
    prometheus = {
      enable = true;
      # checkConfig = false;
      # TODO: Wire this all up centrally somewhere
      # Think about the ports though... it's so ugly wiring them when we're using all defaults...
      webExternalUrl = "https://prometheus.${config.control-node.serviceDomain}/";
      ruleFiles = [./rules/embedded-exporter.yml ./rules/node-exporter.yml];
      alertmanagers = [
        {
          static_configs = [
            {
              targets = [
                "localhost:9093"
              ];
            }
          ];
        }
      ];
      retentionTime = "14d";
      globalConfig = {
        scrape_interval = "30s";
      };
      scrapeConfigs = [
        # TODO: Maybe wire these up to the actual service config?
        (mkLocalScrapeConfig "caddy" 2019)
        (mkLocalScrapeConfig "grafana" 3000)
        (mkLocalScrapeConfig "garage" 3903)
        (mkLocalScrapeConfig "kthxbye" 9099)
        # (mkLocalScrapeConfig "spire-server" 9988)
        # Self-monitoring (fwiw)
        (mkLocalScrapeConfig "alertmanager" 9093)
        (mkLocalScrapeConfig "prometheus" 9090)
        {
          job_name = "machines";
          relabel_configs = promLocalHostRelabelConfigs;
          honor_labels = false;
          static_configs = [
            {
              targets = [
                "localhost:9100"
              ];
              labels = {
                instance = "fat-controller.systems.richtman.au";
              };
            }
            {
              targets = [
                "opnsense.internal:9100"
                "proxmox.internal:9100"
                "mum.systems.richtman.au:9100"
                "patient-zero.systems.richtman.au:9100"
                "dr-singh.systems.richtman.au:9100"
                "smol-bat.systems.richtman.au:9100"
                "tweedledee.systems.richtman.au:9100"
                "tweedledum.systems.richtman.au:9100"
              ];
            }
          ];
        }
      ]; # Ref: https://wiki.nixos.org/wiki/Prometheus
      alertmanager = {
        enable = true;
        # Required to use files in config?
        checkConfig = false;
        # Ref: https://github.com/prometheus/alertmanager/blob/main/doc/examples/simple.yml
        configuration = {
          receivers = [
            {
              name = "null";
            }
            {
              name = "discord";
              discord_configs = [
                {
                  webhook_url = "";
                  # webhook_url_file = "/var/lib/alertmanager/discord-webhook-url";
                }
              ];
            }
          ];
          route = {
            receiver = "discord";
            group_by = ["alertname" "nodename"];
            routes = [
              {
                matchers = [
                  "alertname=\"PrometheusAlertmanagerE2eDeadManSwitch\""
                ];
                receiver = "null";
              }
            ];
          };
        };
      };
    };
  };
}
