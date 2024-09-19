{
  pkgs,
  lib,
  ...
}: let
  # Source: https://samber.github.io/awesome-prometheus-alerts/
  ruleSets = [
    {
      url = "https://raw.githubusercontent.com/samber/awesome-prometheus-alerts/master/dist/rules/prometheus-self-monitoring/embedded-exporter.yml";
      sha256 = "00n6c22qrib6wix31c3q2bp69kaplqm1awyhxawd1r1disp5gi4v";
    }
    {
      url = "https://raw.githubusercontent.com/samber/awesome-prometheus-alerts/master/dist/rules/host-and-hardware/node-exporter.yml";
      sha256 = "12r78fav9gr8bvqbrhk0b24wrcd5162n8ycbiragbkddasipwzgw";
    }
  ];
  downloadedRuleFiles = builtins.map builtins.fetchurl ruleSets;
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
  networking.hostName = "fat-controller";
  virtual-node.enable = true;
  lab-node.enable = true;
  system.stateVersion = "24.11";
  # May be required for IPv6 neighbor discovery?
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  boot.kernel.sysctl."net.ipv6.ip_forward" = 1;
  networking.firewall.extraInputRules = lib.concatStringsSep "\n" [
    # Allow my IPv4 private subnets into HTTPS
    "ip saddr { 192.168.1.0/24,192.168.2.0/24 } tcp dport 443 accept"
    # Allow anything in my primary prefix into HTTPS
    "ip6 saddr { 2403:580a:e4b1::/48 } tcp dport 443 accept"
  ];
  services = {
    k8s.controller = true;
    caddyRP.enabled = true;
    garage = {
      enable = true;
      environmentFile = "/var/lib/garage/.env";
      settings = {
        replication_factor = 1;
        rpc_bind_addr = "[::]:3901";
        s3_api = {
          api_bind_addr = "[::]:3900";
          s3_region = "garage";
        };
        s3_web = {
          bind_addr = "[::]:3902";
          root_domain = ".garage.services.richtman.au";
        };
        admin = {
          api_bind_addr = "[::]:3903";
        };
      };
      package = pkgs.garage;
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
      ruleFiles = downloadedRuleFiles;
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
        (mkLocalScrapeConfig "caddy" 2019)
        (mkLocalScrapeConfig "grafana" 3000)
        (mkLocalScrapeConfig "garage" 3903)
        # Required to silence rule about missing Alertmanager job
        (mkLocalScrapeConfig "alertmanager" 9093)
        # Required to silence rule about missing Prometheus job
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
            ];
          };
        };
      };
    };
  };
}
