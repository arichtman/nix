{
  den,
  lib,
  ...
}: {
  den.schema.host = {
    net = {
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
      controllerAddress = "fat-controller.systems.richtman.au";
    };
    includes = [
      den.batteries.hostname
    ];
  };
}
