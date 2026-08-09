{den, ...}: {
  den.schema.host = {
    net = {
      ip4 = {
        subnetCIDR = "10.128.0.0/24";
      };
      ip6 = {
        routerEUI64 = "aab8:e0ff:fe00:91ef";
        prefix = "2403:581e:ab78";
        # TODO: cross-reference this
        subnetCIDR = "2403:581e:ab78::/64";
        prefixCIDR = "2403:581e:ab78::/48";
        # prefixCIDR = "${self.net.ip6.prefix}::/48";
        # prefixCIDR = "${den.schema.host.net.ip6.prefix}::/48";
      };
      controllerAddress = "fat-controller.systems.richtman.au";
    };
    includes = [
      den.batteries.hostname
      # den.aspects.basic.time
    ];
  };
}
