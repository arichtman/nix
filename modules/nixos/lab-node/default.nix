{
  lib,
  pkgs,
  config,
  options,
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
      volumes = {
        bootUuid = mkOption {
          type = str;
          description = "Boot disk uuid.";
        };
        rootUuid = mkOption {
          type = str;
          description = "Root disk uuid.";
        };
      };
    };
    config = mkIf cfg.enable {
      # Define a user account. Don't forget to set a password with ‘passwd’.
      users.users.nixos = {
        isNormalUser = true;
        description = "nixos";
        extraGroups = ["networkmanager" "wheel"];
        packages = with pkgs; [];
      };

      environment.systemPackages = with pkgs; [
        git
        helix
      ];
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
      # Bootloader.
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      # Configure network proxy if necessary
      # networking.proxy.default = "http://user:password@proxy:port/";
      # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

      # Enable networking
      # TODO: Consider removal of networkmanager
      networking.networkmanager.enable = true;

      # Set your time zone.
      # TODO: Consider switching servers to UTC
      time.timeZone = "Australia/Brisbane";

      # Select internationalisation properties.
      i18n.defaultLocale = "en_AU.UTF-8";

      i18n.extraLocaleSettings = {
        LC_ADDRESS = "en_AU.UTF-8";
        LC_IDENTIFICATION = "en_AU.UTF-8";
        LC_MEASUREMENT = "en_AU.UTF-8";
        LC_MONETARY = "en_AU.UTF-8";
        LC_NAME = "en_AU.UTF-8";
        LC_NUMERIC = "en_AU.UTF-8";
        LC_PAPER = "en_AU.UTF-8";
        LC_TELEPHONE = "en_AU.UTF-8";
        LC_TIME = "en_AU.UTF-8";
      };

      services = {
        openssh = {
          enable = true;
        };
        # Configure keymap in X11
        xserver = {
          layout = "au";
          xkbVariant = "";
        };
        sleep-at-night = {
          enable = true;
          shutdown.hour = 23;
          wakeup.hour = 7;
          weekends = "only";
        };
      };

      # Some programs need SUID wrappers, can be configured further or are
      # started in user sessions.
      # programs.mtr.enable = true;
      # programs.gnupg.agent = {
      #   enable = true;
      #   enableSSHSupport = true;
      # };

      # Open ports in the firewall.
      # networking.firewall.allowedTCPPorts = [ ... ];
      # networking.firewall.allowedUDPPorts = [ ... ];
      # Or disable the firewall altogether.
      # networking.firewall.enable = false;

      # This value determines the NixOS release from which the default
      # settings for stateful data, like file locations and database versions
      # on your system were taken. It‘s perfectly fine and recommended to leave
      # this value at the release version of the first install of this system.
      # Before changing this value read the documentation for this option
      # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
      system.stateVersion = "23.05"; # Did you read the comment?

      # ---- HARDWARE -----
      # Note: This really only works for very homogenous machines.

      boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod"];
      boot.initrd.kernelModules = [];
      boot.kernelModules = ["kvm-intel"];
      boot.extraModulePackages = [];

      fileSystems."/" = {
        device = "/dev/disk/by-uuid/${cfg.volumes.rootUuid}";
        fsType = "ext4";
      };

      fileSystems."/boot" = {
        device = "/dev/disk/by-uuid/${cfg.volumes.bootUuid}";
        fsType = "vfat";
      };

      swapDevices = [];

      # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
      # (the default) this is the recommended approach. When using systemd-networkd it's
      # still possible to use this option, but it's recommended to use it in conjunction
      # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
      networking.useDHCP = lib.mkDefault true;
      networking.interfaces.eno1.wakeOnLan.enable = true;

      # networking.interfaces.eno1.useDHCP = lib.mkDefault true;
      # networking.interfaces.wlp1s0.useDHCP = lib.mkDefault true;

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
      hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    };
  }
