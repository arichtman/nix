{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.lab-node;
  rootCaStoreFile = builtins.fetchurl {
    url = "https://s3.ap-southeast-2.amazonaws.com/richtman.au/root-ca.pem";
    sha256 = "1n0mmybs4alnr0zw049nm01sbrrhkj3idan917lcc6p8ils17psh";
  };
in
  with lib; {
    options.lab-node = with types; {
      enable = mkEnableOption "Turns a machine into one of my minions mwahahaha";
    };
    config = mkIf cfg.enable {
      environment.systemPackages = with pkgs; [
        git
        helix
        step-cli
        jq
        yq
        tcpdump
        trippy
        bpftools
        ethtool
        btop
        sysstat
        linuxKernel.packages.linux_libre.perf
        dig
        file
        pwru
      ];
      nix = {
        settings = {
          trusted-public-keys = lib.mkAfter ["fat-controller.systems.richtman.au:ULbki6cpX8A6Lvpx7XX7HuZ2qaEs0spWpvs+MOad204="];
          auto-optimise-store = true;
          substituters = ["http://fat-controller.systems.richtman.au:5000"];
          download-buffer-size = 134217728;
          build-max-jobs = 2;
          cores = 0;
        };
        optimise.automatic = true;
        gc.automatic = true;
        # optimised for noninteractive
        daemonCPUSchedPolicy = "batch";
      };
      system.autoUpgrade.flake = "github:arichtman/nix";
      # Define a user account.
      users.users.nixos = {
        isNormalUser = true;
        description = "nixos";
        extraGroups = ["networkmanager" "wheel"];
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJt9zJAxzYEK7Y2FYmwkT4cnYr/e4lO2w/ivNL74Pp6B"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBxGxm6tCZlV3vJ6+yAkmQKcqVagfhgaf2aHzVQHvay+"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMB0EONXbHFqCgHpvJDtFVrDyJeNVHb+XeweP+vYHf0F"
        ];
      };

      security = {
        pki.certificateFiles = [
          rootCaStoreFile
        ];
        sudo.wheelNeedsPassword = false;
      };

      # Set your time zone.
      time.timeZone = "UTC";

      # Select internationalisation properties.
      i18n.defaultLocale = "C.UTF-8";

      i18n.extraLocaleSettings = {
        LC_ADDRESS = "C.UTF-8";
        LC_IDENTIFICATION = "C.UTF-8";
        LC_MEASUREMENT = "C.UTF-8";
        LC_MONETARY = "C.UTF-8";
        LC_NAME = "C.UTF-8";
        LC_NUMERIC = "C.UTF-8";
        LC_PAPER = "C.UTF-8";
        LC_TELEPHONE = "C.UTF-8";
        LC_TIME = "C.UTF-8";
      };

      services = {
        k8s.worker = true;
        # TODO: Troubleshoot
        # Allows unofficial well-known FHS paths to work
        # Ref: https://fzakaria.com/2025/02/27/nix-pragmatism-nix-ld-and-envfs.html
        # envfs.enable = true;
        openssh = {
          enable = true;
          # TODO: Disable before opening to internet
          # settings.PasswordAuthentication = false;
        };
        resolved = {
          enable = true;
        };
        journald.extraConfig = ''
          SystemMaxUse=100M
          MaxFileSec=7day
        '';
        prometheus.exporters.process = {
          enable = true;
          openFirewall = true;
          listenAddress = "[::]";
        };
        prometheus.exporters.statsd = {
          enable = true;
          openFirewall = true;
          listenAddress = "[::]";
        };
        prometheus.exporters.systemd = {
          enable = true;
          openFirewall = true;
          listenAddress = "[::]";
        };
        prometheus.exporters.node = {
          enable = true;
          openFirewall = true;
          # I don't think this is strictly necessary for dual stack but eh
          listenAddress = "[::]";
        };
        # Ref: https://github.com/avahi/avahi/blob/master/avahi-daemon/avahi-daemon.conf
        avahi = {
          enable = true;
          publish = {
            enable = true;
            domain = true;
            # TODO: testing all enabled
            workstation = true;
            userServices = true;
            hinfo = true;
            addresses = true;
          };
          nssmdns6 = true;
          nssmdns4 = true;
          ipv6 = true;
          # Required to reduce context switch thrashing
          # Ref: https://askubuntu.com/questions/1130175/avahi-daemon-uses-excessive-amounts-of-cpu
          extraConfig = ''
            [server]
            ratelimit-interval-usec=500000
            ratelimit-burst=500
            [wide-area]
            enable-wide-area=no
          '';
        };
        # Required to respond to neighbor discovery protocol for IPv6 SLAAC
        # mDNS does the name-to-IP, ND does IP-to-MAC
        radvd = {
          enable = true;
          # Leftover from testing, remove before flight
          # prefix ::/64 {};
          # debugLevel = 4;
          config = ''
            interface eno1 {
              AdvSendAdvert on;
            };
          '';
        };
        # Configure keymap in X11
        xserver = {
          xkb = {
            layout = "au";
            variant = "";
          };
        };
        sleep-at-night = {
          enable = false;
          shutdown.hour = 23;
          wakeup.hour = 7;
          weekends = "only";
        };
      };

      boot = {
        # TODO: May not require xt_socket
        # Ref: https://allanjohn909.medium.com/integrating-cilium-with-gateway-api-ipv6-and-bgp-for-advanced-networking-solutions-5b41b0ca0090
        # kernel.sysctl.net.core.devconf_inherit_init_net = 1;
        # kernel.sysctl.net.netfilter.nf_conntrack_max = 196608;
        kernelModules = ["ip6table_mangle" "ip6table_raw" "ip6table_filter"];
        # ++ [ "xt_socket"];
        # May be required for IPv6 neighbor discovery?
        kernel.sysctl."net.ipv4.ip_forward" = 1;
        kernel.sysctl."net.ipv6.ip_forward" = 1;
        tmp.cleanOnBoot = true;
      };
      networking = {
        # TODO: See if this ought to be richtman.au
        domain = "systems.richtman.au";
        search = [
          config.networking.domain
        ];
        # TODO: Consider removal of networkmanager
        networkmanager.enable = true;
        nftables.enable = true;
        # Only allow ingress from ranges I control
        firewall.extraInputRules = lib.concatStringsSep "\n" [
          "ip saddr { ${lib.arichtman.net.ip4.subnet} } tcp dport 443 accept comment \"Allow private IPv4 subnets\""
          "ip6 saddr { ${lib.arichtman.net.ip6.prefixCIDR} } tcp dport 443 accept comment \"Allow my IPv6 prefix\""
          "ip saddr { ${lib.arichtman.net.ip4.subnet} } udp dport 5353 accept comment \"Allow private IPv4 mDNS\""
          "ip6 saddr { ${lib.arichtman.net.ip6.prefixCIDR} } udp dport 5353 accept comment \"Allow IPv6 mDNS\""
          # "ip6 saddr { ${lib.arichtman.net.ip6.prefixCIDR} } tcp dport 4240 accept comment \"Allow IPv6 Cilium health\""
          # TODO: hail mary in case it's nftables dropping stuff
          "ip6 saddr { ${lib.arichtman.net.ip6.prefixCIDR} } tcp dport 9800-9999 accept comment \"Allow IPv6 Cilium health\""
          # "ip6 saddr { ${lib.arichtman.net.ip6.prefixCIDR} } udp dport 53 accept comment \"Allow IPv6 DNS\""
        ];
        # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
        # (the default) this is the recommended approach. When using systemd-networkd it's
        # still possible to use this option, but it's recommended to use it in conjunction
        # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
        useDHCP = lib.mkDefault true;
      };

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    };
  }
