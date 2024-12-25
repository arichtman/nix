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
        kubectl
        step-cli
        k9s
        jq
        yq
        kubernetes-helm
        tcpdump
        trippy
        btop
      ];
      boot.tmp.cleanOnBoot = true;
      nix = {
        settings = {
          trusted-public-keys = lib.mkAfter ["fat-controller.local:nIUqbWD1JiFbdLsKigseHZgj5T8e4Xja0vE0kS1AtHY="];
          auto-optimise-store = true;
          substituters = ["http://fat-controller.local:5000"];
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
      };

      security = {
        pki.certificateFiles = [
          rootCaStoreFile
        ];
        sudo.wheelNeedsPassword = false;
      };

      myKeys = {
        enable = true;
        github = {
          username = "arichtman";
          fileHash = "13h76hlfhnfzd7yjilhwkb9hx5kgmknm30xhq3sqkh6v5h1i1kyv";
        };
        gitlab = {
          username = "arichtman-srt";
          fileHash = "0xq3xxszpgrcha861b2p05hlddm4aa9s2vsr5ri1ak059lwshkc8";
        };
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
        openssh = {
          enable = true;
        };
        journald.extraConfig = ''
          SystemMaxUse=100M
          MaxFileSec=7day
        '';
        prometheus.exporters.node = {
          enable = true;
          openFirewall = true;
          # I don't think this is strictly necessary for dual stack but eh
          listenAddress = "[::]";
        };
        # Ref: https://github.com/avahi/avahi/blob/master/avahi-daemon/avahi-daemon.conf
        avahi = {
          enable = true;
          # domainName = "internal";
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

      boot.kernelModules = ["ip6table_mangle" "ip6table_raw" "ip6table_filter"];
      networking = {
        # TODO: See if this ought to be richtman.au
        domain = "local";
        # TODO: Consider removal of networkmanager
        networkmanager.enable = true;
        nftables.enable = true;
        # Only allow ingress from ranges I control
        firewall.extraInputRules = ''
          ip saddr { 192.168.1.0/24 } udp dport 5353 accept
          ip6 saddr { 2403:580a:e4b1::/48 } udp dport 5353 accept
        '';
        # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
        # (the default) this is the recommended approach. When using systemd-networkd it's
        # still possible to use this option, but it's recommended to use it in conjunction
        # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
        useDHCP = lib.mkDefault true;
        # Required for Calico to manage
        # Ref: https://docs.tigera.io/calico/latest/operations/troubleshoot/troubleshooting#configure-networkmanager
        # networkmanager.unmanaged = ["interface-name:cali*" "interface-name:tunl*" "interface-name:vxlan.calico" "interface-name:vxlan-v6.calico" "interface-name:wireguard.cali" "interface-name:wg-v6.cali"];
      };

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    };
  }
