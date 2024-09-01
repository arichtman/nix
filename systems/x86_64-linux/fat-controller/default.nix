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
    r53-ddns = {
      enable = true;
      zoneID = "Z094201131ER8RBWWZLOL";
      hostname = "services";
      domain = "richtman.dev";
      environmentFile = "/var/lib/r53-ddns/secret.env";
    };
    prometheus = {
      enable = true;
      # Apparently this listens IPv4 also
      # TODO: scale back to localhost only when RP working?
      #   Could also be convenient to access directly from LAN
      listenAddress = "[::]";
      # TODO: Wire this all up centrally somewhere
      # TODO: Find out what fuckery is causing /prometheus/ to redirect to /graph
      # I tried setting Prom's web.external-url to the full thing with and without trailing slash.
      webExternalUrl = "https://services.richtman.dev/";
      retentionTime = "14d";
      scrapeConfigs = [
        {
          job_name = "catdaddy";
          scrape_interval = "15s";
          static_configs = [{
            targets = ["localhost:2019"];
          }];
        }
      ]; # Ref: https://wiki.nixos.org/wiki/Prometheus
      alertmanager = {
        # enable = true;
        configuration = {};
      };
    };
  };
}
