{
  den.aspects.nixOptimizations = {
    nixos = {
      nix = {
        settings = {
          auto-optimise-store = true;
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
    };
  };
}
