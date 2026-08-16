{
  den,
  lib,
  host,
  pkgs,
  ...
}: {
  den.schema.host = rec {
    systemSettings.stateVersion = lib.mkOption {
      description = "System state version.";
      type = lib.types.str;
      example = "24.11";
    };
    fetchGrafanaDashboard = arguments @ {
      id,
      revision,
      name,
      hash ? lib.fakeSha256,
    }:
      builtins.fetchurl {
        url = "https://grafana.com/api/dashboards/${toString id}/revisions/${toString revision}/download";
        name = name;
        sha256 = hash;
      };
    # Ref: https://michael.kjorling.se/blog/2024/prefix-agnostic-ipv6-address-filtering-in-linux-nftables/
    mkNetfilterRuleRouterOnly = service: port: "ip6 saddr & ::ffff:ffff:ffff:ffff == ::${net.ip6.routerEUI64} tcp dport ${lib.toString port} accept comment \"Allow router -> ${service}\"";
    promLocalHostRelabelConfigs = [
      # TODO: Work out why localhost relabel and label override aren't working
      # Relabel localhost so we don't have to open metrics to the world
      {
        source_labels = ["__address__"];
        regex = ".*localhost.*";
        target_label = "instance";
        replacement = net.controllerAddress;
      }
      # Remove port numbers
      {
        source_labels = ["__address__"];
        regex = "(.+):.*";
        target_label = "instance";
        replacement = "\${1}";
      }
    ];
    mkLocalScrapeConfig = name: port: {
      job_name = toString name;
      relabel_configs = promLocalHostRelabelConfigs;
      honor_labels = false;
      static_configs = [
        {
          targets = [
            "localhost:${toString port}"
          ];
          labels = {
            instance = net.controllerAddress;
          };
        }
      ];
    };
    net = rec {
      ip4 = {
        routerCIDR = "10.128.0.1/32";
        subnetCIDR = "10.128.0.0/24";
      };
      ip6 = rec {
        routerEUI64 = "aab8:e0ff:fe00:91ef";
        routerGlobalUnicastAddress = "${prefix}:0:${routerEUI64}";
        prefix = "2403:581e:ab78";
        subnetCIDR = "${prefix}::/64";
        prefixCIDR = "${prefix}::/48";
        wireguardCIDR = "fd2f:f92f:f268::/48";
        mkNetfilterRuleRouterOnly = service: port: "ip6 saddr & ::ffff:ffff:ffff:ffff == ::${routerEUI64} tcp dport ${lib.toString port} accept comment \"Allow router -> ${service}\"";
      };
      primaryDomain = "richtman.au";
      serviceDomain = "services.${primaryDomain}";
      systemDomain = "systems.${primaryDomain}";
      controllerAddress = "fat-controller.${systemDomain}";
    };
    nixos.system.stateVersion = host.systemSettings.stateVersion;
    darwin.stateVersion = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin host.systemSettings.stateVersion;
    includes = [
      # TODO: check out other batteries
      den.batteries.hostname
    ];
  };
}
