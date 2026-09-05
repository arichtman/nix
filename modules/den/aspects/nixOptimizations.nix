{
  den.aspects.nixOptimizations = {
    nixos = {pkgs, ...}: {
      nix = {
        settings = {
          auto-optimise-store = true;
          download-buffer-size = 134217728;
          build-max-jobs = 2;
          cores = 0;
          trusted-users = ["@wheel"];
        };
        optimise.automatic = true;
        gc = {
          automatic = true;
          dates = "weekly";
          options = "--delete-older-than 28d";
        };
        # optimised for noninteractive
        daemonCPUSchedPolicy = "batch";
      };
      systemd = {
        services = {
          nix-optimise = {
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
          # Ref: https://paulxicao.github.io/linux/nixos/2026/01/27/nixos-deleting-generations.html
          prune-nixos-generations = {
            description = "Prune old NixOS system generations";
            serviceConfig = {
              Type = "oneshot";
              ExecStart = ''
                ${pkgs.nix}/bin/nix-env -p /nix/var/nix/profiles/system --delete-generations +28
              '';
            };
          };
        };
        timers.prune-nixos-generations = {
          wantedBy = ["timers.target"];
          timerConfig = {
            OnCalendar = "weekly";
            Persistent = true;
          };
        };
      };
    };
  };
}
