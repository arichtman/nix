{
  lib,
  pkgs,
  config,
  ...
}: {
  # TODO: Can we destructure config?
  config = {
    home = {
      stateVersion = "22.11";
    };
  };
}
