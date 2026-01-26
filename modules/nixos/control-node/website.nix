{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.control-node.enable {
    services.caddy = {
      enable = true;
      virtualHosts = {
        "www.richtman.au:80" = {
          extraConfig = ''
            handle_path /www* {
              import iocaine
              root * /var/lib/caddy/www
              file_server
            }
          '';
        };
      };
    };
    # Ref: https://mich-murphy.com/systemd-services-and-timers-nixos/
    systemd = {
      services.website-update = {
        path = [
          pkgs.git
          pkgs.nix
          # Note: won't be using the devShell version which is a bummer
          # pkgs.zola
        ];
        serviceConfig = {
          Type = "oneshot";
          User = "caddy";
          Group = "caddy";
          ProtectSystem = "full";
          ProtectHome = true;
          NoNewPrivileges = true;
          ReadWritePaths = "/var/lib/caddy";
        };
        script = builtins.readFile ./website-update.sh;
      };
      timers.website-update = {
        wantedBy = ["timers.target"];
        timerConfig = {
          # frequency of the service
          OnCalendar = "hourly";
          # the service to associate the timer with
          Unit = "website-update.service";
        };
      };
    };
  };
}
