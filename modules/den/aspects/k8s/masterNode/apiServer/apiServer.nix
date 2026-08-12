{den, ...}: {
  den.aspects.k8s.masterNode.apiServer = {
    nixos = {
      pkgs,
      lib,
      host,
      ...
    }: let
      serviceArgs = import ./_apiServerArgs.nix {
        inherit pkgs host lib;
        secretsPath = den.aspects.k8s.secretsPath;
      };
    in {
      systemd.services.k8s-apiserver = {
        description = "K8s API server AKA mother brain";
        # Required to activate the service.
        wantedBy = ["kubernetes.target" "multi-user.target"];
        # Wait on networking.
        after = ["network.target"];
        serviceConfig = {
          # For managing resources of groups of services
          Slice = "kubernetes.slice";
          ExecStart = "${pkgs.kubernetes}/bin/kube-apiserver " + serviceArgs;
          WorkingDirectory = "/var/lib/kubernetes";
          # TODO: not sure if there's any nicer way to couple these to the user definition
          User = "kubernetes";
          Group = "kubernetes";
          AmbientCapabilities = "cap_net_bind_service";
          Restart = "on-failure";
          RestartSec = 5;
        };
        unitConfig = {
          StartLimitIntervalSec = 0;
        };
        path = with pkgs; [
          gitMinimal
          openssh
          util-linux
          iproute2
          ethtool
          thin-provisioning-tools
          iptables
          socat
        ];
      };
      services.prometheus.scrapeConfigs = [
        # See impl for why non-default port
        (lib.arichtman.mkLocalScrapeConfig "etcd" 2399)
        # Had to do manually since scheme is https
        {
          job_name = "k8s_apiserver";
          relabel_configs = lib.arichtman.promLocalHostRelabelConfigs;
          honor_labels = false;
          scheme = "https";
          static_configs = [
            {
              targets = [
                "localhost:6443"
              ];
              labels = {
                instance = "${host.networking.hostName}.systems.richtman.au";
              };
            }
          ];
        }
      ];
      # Only allow ingress from ranges I control
      networking.firewall.extraInputRules = ''
        ip6 saddr { ${host.net.ip6.prefixCIDR} } tcp dport 6443 accept comment "Allow LAN APIserver"
        ip6 saddr { ${host.net.ip6.wireguardCIDR} } tcp dport 6443 accept comment "Allow VPN APIserver"
      '';
    };
  };
}
