# Not sure why we need the ... here, docs say aspects don't need it...
# You'd think den would be part of the context, but if we make the nixos {den}:
#   it doesn't proc, so the shape of the arguments must not be matching...
{den, ...}: {
  den.aspects.labNode = {
    includes = [
      den.aspects.trust
      den.aspects.localization
      den.aspects.defaultUser
      den.aspects.debugTools
      den.aspects.binCacheConsumer
      den.aspects.nixOptimizations
      den.aspects.monitoring.systemExporters
      den.aspects.networking
    ];
    nixos = {
      # Enable our lil faves
      nix.settings.experimental-features = ["nix-command" "flakes"];
      system.autoUpgrade.flake = "github:arichtman/nix";
      security.sudo.wheelNeedsPassword = false;

      services = {
        openssh = {
          enable = true;
          # TODO: Harden
          # Ref: https://codeberg.org/ppb1701/nixos-config/src/branch/main/modules/system.nix#L116
        };
        journald.extraConfig = ''
          SystemMaxUse=100M
          MaxFileSec=7day
        '';
        # Ref: https://github.com/NixOS/nixpkgs/issues/408800
        # Ref: https://discourse.nixos.org/t/systemd-exporter-couldnt-get-dbus-connection-read-unix-run-dbus-system-bus-socket-recvmsg-connection-reset-by-peer/64367/4
        dbus.implementation = "broker";
        # Configure keymap in X11
        xserver = {
          xkb = {
            layout = "au";
            variant = "";
          };
        };
      };
      boot = {
        tmp.cleanOnBoot = true;
      };
    };
  };
}
