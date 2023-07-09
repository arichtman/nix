{
  lib,
  pkgs,
  config,
  ...
}: {
  # I'm not even sure these should all _be_ under the top-level config
  # The errors seem to indicate that as long as it's all either way...
  # But our module config has it under *config*.arichtman.default-home
  networking.hostName = "macbookpro";

  #TODO: Determine if this is supposed to be used. Feels like this should be pure system stuff?
  # So... does the user value here translate to which user@system home gets applied?
  # Or should this be a self reference to config.user
  snowfallorg.user.arichtman.home.config.home.file."_systems_x86_64-darwin_macbookpro_default.nix".text = "";

  environment.systemPackages = with pkgs; [
    discord
  ];
  system.stateVersion = 4;
}
