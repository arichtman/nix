{
  lib,
  config,
  pkgs,
  ...
}:
# let
# updateCmd = ''${pkgs.steamcmd}/bin/steamcmd \
#                 +login anonymous \
#                 +force_install_dir $STATE_DIRECTORY \
#                 +app_update 896660 \
#                 +quit'';
# in {
{
  config = lib.mkIf config.control-node.enable {
    services.valheim = {
      enable = true;
      serverName = "hydrohobos";
      worldName = "jboner";
      openFirewall = true;
      crossplay = true;
      noGraphics = true;
      password = "mypass";
      adminList = config.services.valheim.permittedList;
      permittedList = [
        "76561198838658491" # Me
        "76561198021270970" # G
        "76561198010807918" # J
      ];
    };
    # Ref: https://github.com/lukebfox/nix-configs/blob/main/modules/nixos/services/valheim/default.nix
    #   systemd.services.update-valheim = {
    #     serviceConfig = {
    #       Type = "oneshot";
    #       User = "valheim";
    #       StateDirectory = "valheim";
    #       WorkingDirectory = "/var/lib/valheim";
    #     };
    #     script = ''
    #       OUTPUT="$(${updateCmd} | tail -n 1)"
    #       SUCCESS="Success! App '896660' already up to date."
    #       if ! [[ $OUTPUT == $SUCCESS ]]; then
    #           echo "Restarting valheim"
    #           systemctl restart valheim.service
    #       fi
    #     '';
    #     wantedBy = [ "multi-user.target" ];
    #   };

    #   systemd.timers.update-valheim = {
    #     partOf = [ "update-valheim.service" ];
    #     timerConfig.OnCalendar = "*-*-* 8:00:00";
    #     wantedBy = [ "timers.target" ];
    #   };
  };
}
