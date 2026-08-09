let
  rootCaStoreFile = builtins.fetchurl {
    url = "https://www.richtman.au/root-ca.pem";
    sha256 = "1n0mmybs4alnr0zw049nm01sbrrhkj3idan917lcc6p8ils17psh";
  };
in
  # Not sure why we need the ... here, docs say aspects don't need it...
  # You'd think den would be part of the context, but if we make the nixos {den}:
  #   it doesn't proc, so the shape of the arguments must not be matching...
  {den, ...}: {
    den.aspects.lab-node = {
      includes = [den.aspects.k8s.worker];
      nixos = {
        pkgs,
        lib,
        config,
        ...
      }: {
        users.users.nixos = {
          isNormalUser = true;
          extraGroups = ["wheel"];
        };
        environment = {
          shellAliases = {
            sc = "systemctl";
            jc = "journalctl -xeu";

            k = "kubectl";

            nr = "nixos-rebuild";
            nrt = "nr test --flake .";

            sci = "step certificate inspect";
          };
          systemPackages = with pkgs; [
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
            perf
            dig
            file
            pwru
          ];
        };
        nix = {
          settings = {
            trusted-public-keys = lib.mkAfter ["fat-controller.systems.richtman.au:ULbki6cpX8A6Lvpx7XX7HuZ2qaEs0spWpvs+MOad204="];
            auto-optimise-store = true;
            substituters = ["http://fat-controller.systems.richtman.au:5000"];
            download-buffer-size = 134217728;
            build-max-jobs = 2;
            cores = 0;
            trusted-users = ["@wheel"];
          };
          optimise.automatic = true;
          gc.automatic = true;
          # optimised for noninteractive
          daemonCPUSchedPolicy = "batch";
        };
        # Doesn't come with restart by default but is fallible
        systemd.services.nix-optimise = {
          serviceConfig = {
            Restart = "on-failure";
            RestartSec = 5;
          };
          # Might be able to pull up a level to <name>.StartLimitBurst etc
          unitConfig = {
            StartLimitBurst = 5;
            StartLimitIntervalSec = 60;
          };
        };
        system.autoUpgrade.flake = "github:arichtman/nix";
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
          openssh = {
            enable = true;
            # TODO: Harden
            # Ref: https://codeberg.org/ppb1701/nixos-config/src/branch/main/modules/system.nix#L116
          };
          resolved = {
            enable = true;
            settings.Resolve = {
              # Disable built-in resolved Cloudflare+Google+Quad9 etc
              FallbackDNS = [];
            };
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
          # Ref: https://github.com/NixOS/nixpkgs/issues/408800
          # Ref: https://discourse.nixos.org/t/systemd-exporter-couldnt-get-dbus-connection-read-unix-run-dbus-system-bus-socket-recvmsg-connection-reset-by-peer/64367/4
          dbus.implementation = "broker";
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
          # Configure keymap in X11
          xserver = {
            xkb = {
              layout = "au";
              variant = "";
            };
          };
        };
        boot = {
          kernelModules = ["ip6table_mangle" "ip6table_raw" "ip6table_filter"];
          # May be required for IPv6 neighbor discovery?
          kernel.sysctl."net.ipv4.ip_forward" = 1;
          kernel.sysctl."net.ipv6.ip_forward" = 1;
          tmp.cleanOnBoot = true;
        };
        networking = {
          # TODO: See if this ought to be richtman.au
          domain = "systems.richtman.au";
          hosts = {
            "127.0.0.1" = ["localhost4"];
            "::1" = ["localhost6"];
          };
          search = [
            config.networking.domain
          ];
          nftables.enable = true;
          # Only allow ingress from ranges I control
          # TODO: DRY my networking addresses
          firewall.extraInputRules = ''
            ip saddr 10.128.0.1/32 accept comment "Allow router inbound"
            # Prefix-change-durable blanket ingress from the router
            # Ref: https://michael.kjorling.se/blog/2024/prefix-agnostic-ipv6-address-filtering-in-linux-nftables/
            ip6 saddr & ::ffff:ffff:ffff:ffff == ::aab8:e0ff:fe00:91ef accept comment "Allow router inbound regardless of prefix"
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
