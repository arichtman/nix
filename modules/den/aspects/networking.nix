{
  den.aspects.networking = {
    nixos = {host, ...}: {
      services = {
        resolved = {
          enable = true;
          settings.Resolve = {
            # Disable built-in resolved Cloudflare+Google+Quad9 etc
            FallbackDNS = [];
          };
        };
      };
      networking = rec {
        # TODO: See if this ought to be richtman.au
        domain = "systems.richtman.au";
        hosts = {
          "127.0.0.1" = ["localhost4"];
          "::1" = ["localhost6"];
        };
        search = [
          domain
        ];
        nftables.enable = true;
        # Explicitly grant router ingress
        firewall.extraInputRules = ''
          ip saddr ${host.net.ip4.routerCIDR} accept comment "Allow router inbound"
          # Prefix-change-durable blanket ingress from the router
          # Ref: https://michael.kjorling.se/blog/2024/prefix-agnostic-ipv6-address-filtering-in-linux-nftables/
          ip6 saddr & ::ffff:ffff:ffff:ffff == ::${host.net.ip6.routerEUI64} accept comment "Allow router inbound regardless of prefix"
        '';
        useNetworkd = true;
        dhcpcd.enable = false;
      };
      # Ref: https://timeloop.cafe/@uep/115439736391881719
      systemd.network = {
        enable = true;
        config = {
          networkConfig = {
            UseDomains = true;
          };
        };
      };
    };
  };
}
