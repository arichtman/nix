{
  config,
  lib,
  ...
}: let
  mkForAllMachinesScrapeAddress = port: (builtins.map (n: "${n}.systems.richtman.au:${builtins.toString port}") [
    "${config.networking.hostName}"
    # Disabled due to home lab packdown for moving
    # TODO: Re-enable when all plugged back in
    # "patient-zero"
    # "dr-singh"
    # "smol-bat"
    # "tweedledee"
    # "tweedledum"
  ]);
in {
  config.services = lib.mkIf config.control-node.enable {
    prometheus = {
      enable = true;
      # checkConfig = false;
      # TODO: Wire this all up centrally somewhere
      # Think about the ports though... it's so ugly wiring them when we're using all defaults...
      webExternalUrl = "https://prometheus.${config.control-node.serviceDomain}/";
      ruleFiles = [./rules/embedded-exporter.yaml ./rules/node-exporter.yaml ./rules/etcd-contrib.yaml ./rules/k8s.yaml ./rules/pve.yaml];
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
        (lib.arichtman.mkLocalScrapeConfig "grafana" config.services.grafana.settings.server.http_port)
        (lib.arichtman.mkLocalScrapeConfig "kthxbye" config.services.kthxbye.port)
        # Self-monitoring (fwiw)
        (lib.arichtman.mkLocalScrapeConfig "alertmanager" config.services.prometheus.alertmanager.port)
        (lib.arichtman.mkLocalScrapeConfig "prometheus" config.services.prometheus.port)
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
          relabel_configs = lib.arichtman.promLocalHostRelabelConfigs;
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
          relabel_configs = [
            #   {
            #     source_labels = ["__address__"];
            #     target_label = "__param_target";
            #   }
            #   {
            #     source_labels = ["__param_target"];
            #     target_label = "instance";
            #   }
            {
              target_label = "instance";
              replacement = "proxmox.internal";
            }
          ];
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
          inhibit_rules = [
            {
              source_matchers = [
                ''utility = "inhibition"''
              ];
              target_matchers = [
              ];
              equal = ["instance"];
            }
          ];
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
            {
              name = "discord-paging";
              discord_configs = [
                {
                  webhook_url_file = "/var/lib/alertmanager/discord-paging-webhook-url";
                }
              ];
            }
            {
              name = "healthchecks-io";
              webhook_configs = [
                {
                  send_resolved = false;
                  url_file = "/var/lib/alertmanager/healthchecks-io-webhook-url";
                }
              ];
            }
          ];
          route = {
            receiver = "discord";
            group_by = ["alertname" "nodename"];
            routes = [
              {
                receiver = "healthchecks-io";
                matchers = [
                  "alertname=\"PrometheusAlertmanagerE2eDeadManSwitch\""
                ];
                continue = false;
              }
              {
                # Suppress inhibit-only alerts
                receiver = "null";
                matchers = [
                  ''utility = "inhibition"''
                ];
                continue = false;
              }
              {
                receiver = "discord-paging";
                matchers = [
                  ''severity =~ "critical|error"''
                ];
                continue = false;
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
