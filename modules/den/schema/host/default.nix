{den, ...}: {
  den.schema.host = {
    net = {
      ip4 = {
        routerCIDR = "10.128.0.1/32";
        subnetCIDR = "10.128.0.0/24";
      };
      ip6 = rec {
        routerEUI64 = "aab8:e0ff:fe00:91ef";
        prefix = "2403:581e:ab78";
        subnetCIDR = "${prefix}::/64";
        prefixCIDR = "${prefix}::/48";
      };
      controllerAddress = "fat-controller.systems.richtman.au";
    };
    includes = [
      den.batteries.hostname
    ];
  };
}
