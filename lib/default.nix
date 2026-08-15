{lib, ...}: let
in rec {
  net = {
    controllerAddress = "fat-controller.systems.richtman.au";
    ip6 = {
      prefix = "2403:581e:ab78";
      prefixCIDR = "${net.ip6.prefix}::/48";
      subnetCIDR = "${net.ip6.prefix}::/64";
      wireguardCIDR = "fd00:f423:5624:9f39::/64";
      routerLinkLocalAddress = "fe80::1ced:c0ff:fed0:0dad";
      routerEUI64 = "aab8:e0ff:fe00:91ef";
      routerGlobalUnicastAddress = "${net.ip6.prefix}:0:${net.ip6.routerEUI64}";
    };
    ip4 = {
      routerCIDR = "10.128.0.1/32";
      subnetCIDR = "10.128.0.0/24";
    };
  };
}
