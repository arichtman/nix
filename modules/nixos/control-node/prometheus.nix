{
  config,
  lib,
  ...
}: let
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
          instance = "${config.networking.hostName}.systems.richtman.au";
        };
      }
    ];
  };
  mkForAllMachinesScrapeAddress = port: (builtins.map (n: "${n}.systems.richtman.au:${builtins.toString port}") [
    "${config.networking.hostName}"
    "patient-zero"
    "dr-singh"
    "smol-bat"
    "tweedledee"
    "tweedledum"
  ]);
  promLocalHostRelabelConfigs = [
    # TODO: Work out why localhost relabel and label override aren't working
    # Relabel localhost so we don't have to open metrics to the world
    {
      source_labels = ["__address__"];
      regex = ".*localhost.*";
      target_label = "instance";
      replacement = "${config.networking.hostName}.systems.richtman.au";
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
  config.services = lib.mkIf config.control-node.enable {
    prometheus = {
      enable = true;
      # checkConfig = false;
      # TODO: Wire this all up centrally somewhere
      # Think about the ports though... it's so ugly wiring them when we're using all defaults...
      webExternalUrl = "https://prometheus.${config.control-node.serviceDomain}/";
      ruleFiles = [./rules/embedded-exporter.yaml ./rules/node-exporter.yaml ./rules/etcd-contrib.yaml ./rules/k8s.yaml];
      alertmanagers = [
        {
          static_configs = [
            {
              targets = [
                "localhost:${toString config.services.prometheus.alertmanager.port}"
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
        # See impl for why non-default port
        (mkLocalScrapeConfig "etcd" 2399)
        (mkLocalScrapeConfig "grafana" config.services.grafana.settings.server.http_port)
        (mkLocalScrapeConfig "tempo" 3200)
        (mkLocalScrapeConfig "garage" 3903)
        # Had to do manually since scheme is https
        {
          job_name = "k8s_apiserver";
          relabel_configs = promLocalHostRelabelConfigs;
          honor_labels = false;
          scheme = "https";
          static_configs = [
            {
              targets = [
                "localhost:6443"
              ];
              labels = {
                instance = "${config.networking.hostName}.systems.richtman.au";
              };
            }
          ];
        }
        (mkLocalScrapeConfig "kthxbye" config.services.kthxbye.port)
        (mkLocalScrapeConfig "spire-server" 9988)
        # TODO: Renable when agent is working
        # (mkLocalScrapeConfig "spire-agent" 9989)
        # Self-monitoring (fwiw)
        (mkLocalScrapeConfig "alertmanager" config.services.prometheus.alertmanager.port)
        (mkLocalScrapeConfig "prometheus" config.services.prometheus.port)
        {
          job_name = "containerd";
          metrics_path = "v1/metrics";
          # This totally fucked my cardinality
          # Hindsight not sure why, should just be a counter
          # Maybe the labels on the gRPC server change a lot
          metric_relabel_configs = [
            {
              source_labels = ["__name__"];
              regex = "grpc_server_handled_total";
              action = "drop";
            }
          ];
          static_configs = [
            {
              targets = mkForAllMachinesScrapeAddress 9103;
            }
          ];
        }
        {
          job_name = "node_processes";
          static_configs = [
            {
              targets = mkForAllMachinesScrapeAddress 9256;
            }
          ];
        }
        {
          job_name = "node_stats";
          static_configs = [
            {
              targets = mkForAllMachinesScrapeAddress 9102;
            }
          ];
        }
        {
          job_name = "node_services";
          static_configs = [
            {
              targets = mkForAllMachinesScrapeAddress 9558;
            }
          ];
        }
        {
          job_name = "nodes";
          relabel_configs = promLocalHostRelabelConfigs;
          honor_labels = false;
          static_configs = [
            {
              targets =
                [
                  "opnsense.internal:9100"
                  "proxmox.internal:9100"
                ]
                ++ mkForAllMachinesScrapeAddress 9100;
            }
          ];
        }
        # Ref: https://github.com/prometheus-pve/prometheus-pve-exporter#prometheus-configuration
        {
          job_name = "pve";
          metrics_path = "/pve";
          # params = {
          #   module = ["default"];
          #   cluster = ["1"];
          #   node = ["1"];
          # };
          # relabel_configs = [
          #   {
          #     source_labels = ["__address__"];
          #     target_label = "__param_target";
          #   }
          #   {
          #     source_labels = ["__param_target"];
          #     target_label = "instance";
          #   }
          #   {
          #     target_label = "__address__";
          #     replacement = "proxmox.internal";
          #   }
          # ];
          static_configs = [
            {
              targets = [
                "proxmox.internal:9221"
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
                  webhook_url_file = "/var/lib/alertmanager/discord-webhook-url";
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
              reverse_proxy localhost:${toString config.services.prometheus.port}
            }
          '';
        };
        "alertmanager.services.richtman.au:80" = {
          extraConfig = ''
            handle_path /alertmanager* {
              reverse_proxy localhost:${toString config.services.prometheus.alertmanager.port}
            }
          '';
        };
      };
    };
    grafana.provision.datasources.settings.datasources = [
      {
        name = "prometheus";
        type = "prometheus";
        url = "http://localhost:${toString config.services.prometheus.port}";
        isDefault = true;
      }
    ];
  };
}
