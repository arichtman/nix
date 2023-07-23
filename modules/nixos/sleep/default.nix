# Credit: Felix Springer aka jumper149
# Ref: https://www.reddit.com/r/NixOS/comments/kn1pvj/comment/ghif5jg/
{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.services.sleep-at-night;
  sleep-at-night = pkgs.writeScriptBin "sleep-at-night" ''
    #!${pkgs.bash}/bin/bash
    shutdownHour="00$1"
    shutdownHour="''${shutdownHour:(-2)}"
    shutdownMinute="00$2"
    shutdownMinute="''${shutdownMinute:(-2)}"
    wakeupHour="00$3"
    wakeupHour="''${wakeupHour:(-2)}"
    wakeupMinute="00$4"
    wakeupMinute="''${wakeupMinute:(-2)}"
    currentHour="$(${pkgs.coreutils}/bin/date +%H)"
    currentMinute="$(${pkgs.coreutils}/bin/date +%M)"
    if [[ "$currentHour" -eq "$shutdownHour" && "$currentMinute" -eq "$shutdownMinute" ]] || [[ "$currentHour" -gt "$shutdownHour" ]]
    then
        echo "Shutting down now. Waking up at $wakeupTime".
        ${pkgs.utillinux}/bin/rtcwake --mode off --time "$(${pkgs.coreutils}/bin/date --date "$wakeupHour$wakeupMinute" +%s)";
    else
        echo "Shutting down at $shutdownHour:$shutdownMinute."
        exit 0
    fi
  '';
in
  with lib; {
    options = {
      services.sleep-at-night = {
        enable = mkOption {
          default = false;
          type = with types; bool;
          description = ''
            Sleep at night.
            If you start the system after the given `shutdown` time, the system will keep running until the `shutdown` time occurs again, even if you start it before the given `wakeup` time.
          '';
        };

        timer.granularity = mkOption {
          default = 5;
          type = with types; ints.between 1 59;
          description = ''
            Frequency in minutes to check if system should start sleeping.
            Effectively the variance of start and finish times.
          '';
        };

        wakeup = {
          hour = mkOption {
            default = 01;
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
            default = 01;
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
        serviceConfig = {
          ExecStart = "${sleep-at-night}/bin/sleep-at-night ${toString cfg.shutdown.hour} ${toString cfg.shutdown.minute} ${toString cfg.wakeup.hour} ${toString cfg.wakeup.minute}";
          Restart = "on-success";
          RestartSec = cfg.timer.granularity * 60;
          User = "root";
        };
        wantedBy = ["multi-user.target"];
      };
    };
  }
