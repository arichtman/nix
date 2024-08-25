{pkgs, ...}: {
  networking.hostName = "fat-controller";
  virtual-node.enable = true;
  lab-node.enable = true;
  system.stateVersion = "24.11";
  # TODO: remove the hail mary of localhost 443 ingress
  networking.firewall.extraInputRules = ''
    ip saddr { 192.168.1.0/24 } tcp dport 443 accept
    ip6 saddr { 2403:580a:e4b1::/48 } tcp dport 443 accept
    ip saddr { 127.0.0.1/32 } tcp dport 9090 accept
    ip6 saddr { ::1/128 } tcp dport 9090 accept
  '';
  services.k8s.controller = true;
  services = {
    nginx = {
      enable = true;
      # this isn't behaving to send to syslog??
      # logError = "/tmp/nginx.log debug";
      logError = "stderr debug";
      upstreams = {
        prometheus = {
          servers = {
            "localhost:9090" = {};
          };
        };
      };
      # TODO: re-add. Noisy for examining config
      # recommendedProxySettings = true;
      # recommendedOptimisation = true;
      # recommendedGzipSettings = true;
      # recommendedBrotliSettings = true;
      # recommendedTlsSettings = true;
      # recommendedZstdSettings = true;
      # Note: this seems to prevent it from trying to serve static HTML/files from a directory
      defaultListen = [
        {
          addr = "0.0.0.0";
          proxyProtocol = true;
          ssl = true;
        }
        {
          addr = "[::0]";
          proxyProtocol = true;
          ssl = true;
        }
      ];
      virtualHosts = {
        "fat-controller.internal" = {
          sslCertificate = "/var/nginx/ssl/nginx-ssl.pem";
          sslCertificateKey = "/var/nginx/ssl/nginx-ssl.key";
          # serverName = "";
          # onlySSL = true;
          forceSSL = true;
          locations = {
            "/prometheus/" = {
              proxyPass = "http://localhost:9090/";
              extraConfig = ''
                rewrite  ^/prometheus(.*)$ $1 break;
              '';
              # This didn't fix it either
              # proxyPass = "http://127.0.0.1:9090";
            };
            "/" = {
              # proxyPass = "http://prometheus$request_uri";
              # proxyPass = "http://prometheus/";
              proxyPass = "http://localhost:9090/";
            };
            # alertManager = {
            #   proxyPass = "http://localhost:9093";
            # };
          };
        };
      };
    };
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
