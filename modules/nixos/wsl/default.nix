{ options, config, lib, pkgs, ... }:
let
  cfg = config.arichtman.wsl;
in
#TODO: Revisit the use of lib
with lib;
# with lib.internal;
{
  options.arichtman.wsl = {
    enable = lib.mkEnableOption "Apply WSL configuration.";
  };
  config = mkIf cfg.enable {
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
      wantedBy = [ "sysinit.target" "systemd-tmpfiles-setup-dev.service" "sytemd-tmpfiles-setup.service" "systemd-sysctl.service" ];
    };
    #TODO: factor this stuff into a common module
    time.timeZone = "Australia/Brisbane";

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
      extraGroups = [ "docker" "wheel" ];
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
        wget
        git
        direnv
        nix-direnv
        home-manager
        helix
        ripgrep
        zoxide
        nnn
      ];
      shellAliases = {
        pls = "please";
      };
      variables = {
        EDITOR = "hx";
      };
    };
    # I wanted to do a generic loginShellInit but $SHELL is set to <SHELL> in context
    # There's probably a Nix context value I can use but I don't know it
    programs.bash.loginShellInit = ''
      eval "$(zoxide init bash)"
    '';
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

