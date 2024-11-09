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
          instance = "fat-controller.local";
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
      replacement = "fat-controller.local";
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
  options.services.monitoring = {
    enable = lib.options.mkOption {
      description = "Enables my monitoring stack";
      default = false;
      type = lib.types.bool;
    };
  };
  config.services = lib.mkIf config.services.monitoring.enable {
    nix-serve = {
      enable = true;
      openFirewall = true;
      secretKeyFile = "/var/lib/nix-serve/cache-priv-key.pem";
    };
    kthxbye = {
      enable = true;
      port = 9099;
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
      # TODO: Wire this all up centrally somewhere
      # Think about the ports though... it's so ugly wiring them when we're using all defaults...
      webExternalUrl = "https://prometheus.services.richtman.au/";
      ruleFiles = [./embedded-exporter.yml ./node-exporter.yml];
      alertmanagers = [
        {
          scheme = "http";
          path_prefix = "/alertmanager";
          static_configs = [
            {
              targets = [
                "localhost"
              ];
            }
          ];
        }
      ];
      retentionTime = "14d";
      exporters.node.enable = true;
      globalConfig = {
        scrape_interval = "30s";
      };
      scrapeConfigs = [
        # TODO: Maybe wire these up to the actual service config?
        (mkLocalScrapeConfig "caddy" 2019)
        (mkLocalScrapeConfig "grafana" 3000)
        (mkLocalScrapeConfig "garage" 3903)
        (mkLocalScrapeConfig "kthxbye" 9099)
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
                instance = "fat-controller.local";
              };
            }
            {
              targets = [
                "opnsense.internal:9100"
                "proxmox.internal:9100"
                "patient-zero.local:9100"
                "dr-singh.local:9100"
                "smol-bat.local:9100"
                "tweedledee.local:9100"
                "tweedledum.local:9100"
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
              # Null route Wireguard errors
              # The interface typically isn't transmitting anything so errors cause divide by zero +Inf firing
              {
                matchers = [
                  "alertname=\"HostNetworkTransmitErrors\""
                  "device=\"wg0\""
                  "nodename=\"opnsense\""
                ];
                receiver = "null";
              }
              # Null route the weird tmpfs Nixos error
              # TODO: Fix root cause
              {
                matchers = [
                  "alertname=\"HostFilesystemDeviceError\""
                  "mountpoint=\"/run/user/1000\""
                  "device=\"tmpfs\""
                  "fstype=\"tmpfs\""
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
