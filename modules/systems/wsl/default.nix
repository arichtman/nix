{ options, config, lib, pkgs, ... }:
let
  cfg = config.arichtman.wsl;
in
#TODO: Revisit the use of lib
with lib;
# with lib.internal;
{
  options.arichtman.wsl = with types; {
    enable = mkOption { 
      type = bool;
      default = false;
      description = "Apply WSL configuration.";
    };
  };
  config = mkIf cfg.enable {
    services.yubikey-agent.enable = true;
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
    #TODO: factor this stuff into a common module
    time.timeZone = "Australia/Brisbane";
    boot.tmp.useTmpfs = true;

    services.ntp = {
      enable = true;
      servers = [
        "pool.ntp.org"
      ];
    };

    networking.useDHCP = true;

    wsl = {
      enable = true;
      wslConf.automount.root = "/mnt";
      defaultUser = "nixos";
      startMenuLaunchers = true;
      #nativeSystemd = true;
      # Enable native Docker support
      docker-native.enable = true;
    };

    users.users.nixos = {
      extraGroups = ["docker" "wheel"];
      isNormalUser = true;
    };

    virtualisation.docker = {
      autoPrune.enable = true;
      enable = true;
      rootless.enable = true;
      rootless.setSocketVariable = true;
    };

    # Set system packages
    environment = {
      systemPackages = with pkgs; [
        home-manager
      ];
      shellAliases = {
        pls = "please";
      };
    };
    security = {
      please = {
        enable = true;
        wheelNeedsPassword = false;
      };
    };
    # Enable VSCode server fixer service
    # TODO: Isn't this dependent on the module being imported?
    #   Is this coupling safe? Isn't it some implicit stuff?
    services.vscode-server.enable = true;
    # Enable unfree packages (for vscode, mostly)
    nixpkgs.config.allowUnfree = true;

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