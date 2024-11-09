{
  pkgs,
  lib,
  ...
}: {
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
    monitoring.enable = true;
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
  };
}
