{
  options,
  config,
  lib,
  pkgs,
  ...
}: let
  #TODO: Set this up as optional config again
  # cfg = config.wsl-system;
in
  #TODO: Revisit the use of lib
  with lib;
  # with lib.internal;
    {
      # options.wsl-system = {
      #   enable = lib.mkEnableOption "Apply WSL configuration.";
      # };
      # config = mkIf cfg.enable {
      config = {
        # https://github.com/nix-community/NixOS-WSL/issues/185
        systemd.services.nixs-wsl-systemd-fix = {
          description = "Fix the /dev/shm symlink to be a mount";
          unitConfig = {
            DefaultDependencies = "no";
            Before = "sysinit.target";
            ConditionPathExists = "/dev/shm";
            ConditionPathIsSymbolicLink = "/dev/shm";
            ConditionPathIsMountPoint = "/run/shm";
          };
          serviceConfig = {
            Type = "oneshot";
            ExecStart = [
              "${pkgs.coreutils-full}/bin/rm /dev/shm"
              "/run/wrappers/bin/mount --bind -o X-mount.mkdir /run/shm /dev/shm"
            ];
          };
          wantedBy = ["sysinit.target" "systemd-tmpfiles-setup-dev.service" "sytemd-tmpfiles-setup.service" "systemd-sysctl.service"];
        };
        wsl = {
          enable = true;
          wslConf.automount.root = "/mnt";
          defaultUser = "nixos";
          startMenuLaunchers = true;
          #nativeSystemd = true;
          # Enable native Docker support
          docker-native.enable = true;
        };

        #TODO: factor this stuff into a common systems module
        time.timeZone = "Australia/Brisbane";
        services.ntp = {
          enable = true;
          servers = [
            "pool.ntp.org"
          ];
        };
        networking.useDHCP = true;
        # Set system packages
        environment = {
          systemPackages = with pkgs; [
            #TODO: trim
            git
            home-manager
            ripgrep
          ];
          shellAliases = {
            pls = "please";
          };
          variables = {
            EDITOR = "hx";
          };
        };
        #endregion systems module

        #TODO: This shouldn't be in the WSL module...
        # users.users.nixos = {
        #   extraGroups = [ "docker" "wheel" ];
        #   isNormalUser = true;
        # };

        virtualisation.docker = {
          autoPrune.enable = true;
          enable = true;
          rootless.enable = true;
          rootless.setSocketVariable = true;
        };

        security = {
          please = {
            enable = true;
            wheelNeedsPassword = false;
          };
        };

        nix = {
          settings = {
            auto-optimise-store = true;
          };
          # Enable flakes and CLI v3
          extraOptions = ''
            experimental-features = nix-command flakes
          '';
          # TODO: Use this or the nix.extraOptions?
          package = pkgs.nixFlakes;
        };
        # TODO: Should we set this both here _and_ in home-manager?
        # TODO: Will using unstable/master nixpkgs/h-m have any affects with this?
        system.stateVersion = "22.11";
      };
    }
