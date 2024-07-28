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
      boot.tmp.cleanOnBoot = true;
      # TODO: Pretty sure this defaults to 0 anyways...
      nix.settings.cores = 0;
      services.journald.extraConfig = ''
        SystemMaxUse=100M
        MaxFileSec=7day
      '';
      system.autoUpgrade.flake = "github:arichtman/nix";
      nix.optimise.automatic = true;
      nix.gc.automatic = true;
      # optimised for noninteractive
      nix.daemonCPUSchedPolicy = "batch";
      # Define a user account.
      users.users.nixos = {
        isNormalUser = true;
        description = "nixos";
        extraGroups = ["networkmanager" "wheel"];
        packages = with pkgs; [
          git
          helix
          kubectl
          step-cli
          k9s
          jq
          yq
          kubernetes-helm
        ];
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
        openssh = {
          enable = true;
        };
        # Configure keymap in X11
        xserver = {
          xkb = {
            layout = "au";
            variant = "";
          };
        };
        sleep-at-night = {
          enable = true;
          shutdown.hour = 23;
          wakeup.hour = 7;
          weekends = "only";
        };
      };

      # Enable networking
      # TODO: Consider removal of networkmanager
      networking.networkmanager.enable = true;
      # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
      # (the default) this is the recommended approach. When using systemd-networkd it's
      # still possible to use this option, but it's recommended to use it in conjunction
      # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
      networking.useDHCP = lib.mkDefault true;
      # Required for Calico to manage
      # Ref: https://docs.tigera.io/calico/latest/operations/troubleshoot/troubleshooting#configure-networkmanager
      # networking.networkmanager.unmanaged = ["interface-name:cali*" "interface-name:tunl*" "interface-name:vxlan.calico" "interface-name:vxlan-v6.calico" "interface-name:wireguard.cali" "interface-name:wg-v6.cali"];

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    };
  }
