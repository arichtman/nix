{
  pkgs,
  lib,
  config,
  ...
}: {
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
    prometheus = {
      enable = true;
      listenAddress = "[::1]";
      # TODO: Wire this all up centrally somewhere
      # TODO: Find out what fuckery is causing /prometheus/ to redirect to /graph
      # I tried setting Prom's web.external-url to the full thing with and without trailing slash.
      webExternalUrl = "https://fat-controller.local/";
      retentionTime = "14d";
      scrapeConfigs = [
        {
          job_name = "catdaddy";
          scrape_interval = "15s";
          static_configs = [
            {
              targets = ["localhost:2019"];
            }
          ];
        }
        {
          job_name = "sixth-sense";
          scrape_interval = "15s";
          static_configs = [
            {
              targets = ["opnsense.internal:9100"];
            }
          ];
        }
      ]; # Ref: https://wiki.nixos.org/wiki/Prometheus
      alertmanager = {
        # enable = true;
        configuration = {};
      };
    };
  };
}
