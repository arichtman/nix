# Credit: Felix Springer aka jumper149
# Ref: https://www.reddit.com/r/NixOS/comments/kn1pvj/comment/ghif5jg/
{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.services.sleep-at-night;
  cronJobCommandStringDefinition = ''${pkgs.utillinux}/bin/rtcwake --mode off --time "$(${pkgs.coreutils}/bin/date --date "${toString cfg.wakeup.hour}:${toString cfg.wakeup.minute}" +%s)"'';
  # TODO: There's surely a nicer switch-case or match or map function...
  cronDaysOfWeek =
    if cfg.weekends == "never"
    then "1-5"
    else
      (
        if cfg.weekends == "only"
        then "0,6"
        else "*"
      );
  cronJobTimeDefinition = "${toString cfg.shutdown.minute} ${toString cfg.shutdown.hour} * * ${cronDaysOfWeek}";
  cronJobStringDefinition = lib.concatStringsSep " " [cronJobTimeDefinition "root" cronJobCommandStringDefinition];
in
  with lib; {
    options = {
      services.sleep-at-night = {
        enable = mkOption {
          default = false;
          type = with types; bool;
          description = ''
            Cron-triggered system sleep.
          '';
        };
        weekends = mkOption {
          type = with types; enum ["always" "never" "only"];
          default = "always";
          description = ''
            Whether to apply on weekends.
            `Only` disables weekdays entirely.
          '';
        };

        wakeup = {
          hour = mkOption {
            default = 7;
            type = with types; ints.between 0 23;
            description = ''
              Wake up at given hour.
            '';
          };
          minute = mkOption {
            default = 0;
            type = with types; ints.between 0 59;
            description = ''
              Wake up at given minute of the given `hour`.
            '';
          };
        };

        shutdown = {
          hour = mkOption {
            default = 23;
            type = with types; ints.between 0 23;
            description = ''
              Shut down at given hour.
            '';
          };
          minute = mkOption {
            default = 0;
            type = with types; ints.between 0 59;
            description = ''
              Shut down at given minute of the given `hour`.
            '';
          };
        };
      };
    };

    config = mkIf cfg.enable {
      services.cron = {
        enable = true;
        systemCronJobs = [
          cronJobStringDefinition
        ];
      };
    };
  }
