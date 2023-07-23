# Credit: Felix Springer aka jumper149
# Ref: https://www.reddit.com/r/NixOS/comments/kn1pvj/comment/ghif5jg/
{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.services.sleep-at-night;
  commandDefinition = "${pkgs.utillinux}/bin/rtcwake --mode off --time \"$(${pkgs.coreutils}/bin/date --date \"${toString cfg.wakeup.hour}:${toString cfg.wakeup.minute}\" '+%s')\"";
  # TODO: There's surely a nicer switch-case or match or map function...
  # daysOfWeek = if cfg.weekends == "never" then "Mon..Fri" else (if cfg.weekends == "only" then "Sat,Sun" else "");
  # The trailing space is dumb as hell but I can't find a whitespace trim function
  #  or a simple drop all list items that are falsy/empty/null
  #  AND lib.concatStringsSep isn't smart enough to recognise an empty list item >:[
  daysOfWeek = builtins.replaceStrings ["always" "never" "only"] ["" "Mon..Fri " "Sat,Sun "] cfg.weekends;
  startAtDefinition = "${daysOfWeek}${toString cfg.shutdown.hour}:${toString cfg.shutdown.minute}";
  sleep-at-night = pkgs.writeScriptBin "sleep-at-night" ''
    #!${pkgs.bash}/bin/bash
    ${pkgs.utillinux}/bin/rtcwake --mode off --time $(${pkgs.coreutils}/bin/date --date ${toString cfg.wakeup.hour}:${toString cfg.wakeup.minute} +%s)
  '';
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
            default = 07;
            type = with types; ints.between 0 23;
            description = ''
              Wake up at given hour.
            '';
          };
          minute = mkOption {
            default = 00;
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
            default = 00;
            type = with types; ints.between 0 59;
            description = ''
              Shut down at given minute of the given `hour`.
            '';
          };
        };
      };
    };

    config = mkIf cfg.enable {
      systemd.services.sleep-at-night = {
        description = "Sleep at night.";
        startAt = startAtDefinition;
        # I tried using the actual command with scriptArgs
        # It's cooked. This works at least.
        script = "${sleep-at-night}/bin/sleep-at-night";
        serviceConfig = {
          User = "root";
        };
      };
    };
  }
