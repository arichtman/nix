{
  pkgs,
  lib,
  config,
  ...
}: let
  downloadedRuleFile = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/samber/awesome-prometheus-alerts/master/dist/rules/host-and-hardware/node-exporter.yml";
    sha256 = "12r78fav9gr8bvqbrhk0b24wrcd5162n8ycbiragbkddasipwzgw";
  };
  downloadedRuleFiles = [downloadedRuleFile];
  promLocalHostRelabelConfigs = [
    # Relabel localhost so we don't have to open metrics to the world
    {
      source_labels = ["__address__"];
      regex = "(localhost):.*";
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
  networking.firewall.extraInputRules = lib.concatStringsSep "\n" [
    # Allow my IPv4 private subnets into HTTPS
    "ip saddr { 192.168.1.0/24,192.168.2.0/24 } tcp dport 443 accept"
    # Allow anything in my primary prefix into HTTPS
    "ip6 saddr { 2403:580a:e4b1::/48 } tcp dport 443 accept"
  ];
  services = {
    k8s.controller = true;
    caddyRP.enabled = true;
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
      webExternalUrl = "https://fat-controller.local/";
      ruleFiles = downloadedRuleFiles;
      retentionTime = "14d";
      exporters.node.enable = true;
      # TODO: Configure global defaults
      scrapeConfigs = [
        {
          job_name = "caddy";
          scrape_interval = "15s";
          relabel_configs = promLocalHostRelabelConfigs;
          static_configs = [
            {
              targets = ["localhost:2019"];
            }
          ];
        }
        {
          job_name = "monitoring";
          scrape_interval = "15s";
          relabel_configs = promLocalHostRelabelConfigs;
          static_configs = [
            {
              targets = [
                "localhost:9090"
                "localhost:3000"
                "localhost:9093"
              ];
            }
          ];
        }
        {
          job_name = "machines";
          scrape_interval = "15s";
          relabel_configs = promLocalHostRelabelConfigs;
          static_configs = [
            {
              targets = [
                "localhost:9100"
                "opnsense.internal:9100"
                "proxmox.internal:9100"
              ];
            }
          ];
        }
      ]; # Ref: https://wiki.nixos.org/wiki/Prometheus
      alertmanager = {
        enable = true;
        # Required to use files in config?
        # checkConfig = false;
        configuration = {
          receivers = [
            {
              name = "discord";
              discord_configs = [
                {
                  webhook_url = "";
                  # webhook_url_file = "/var/lib/alertmanager/discord-webhook-url.txt";
                }
              ];
            }
          ];
          route = {
            receiver = "discord";
          };
        };
      };
    };
  };
}
