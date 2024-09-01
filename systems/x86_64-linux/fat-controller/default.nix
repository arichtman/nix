{pkgs, ...}: {
  networking.hostName = "fat-controller";
  virtual-node.enable = true;
  lab-node.enable = true;
  system.stateVersion = "24.11";
  # TODO: remove the hail mary of localhost 443 ingress
  networking.firewall.extraInputRules = ''
    ip saddr { 192.168.1.0/24 } tcp dport 443 accept
    ip saddr { 192.168.2.0/24 } tcp dport 443 accept
    ip saddr { 127.0.0.1/32 } tcp dport 9090 accept
    ip6 saddr { 2403:580a:e4b1::/48 } tcp dport 443 accept
    ip6 saddr { ::1/128 } tcp dport 9090 accept
  '';
  services = {
    k8s.controller = true;
    prometheus = {
      enable = true;
      webExternalUrl = "/prometheus/";
      alertmanager = {
        # enable = true;
        configuration = {};
      };
    };
  };
}
