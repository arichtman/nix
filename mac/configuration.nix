{ pkgs, lib, ...}:
{
  nixpkgs.config.allowUnfree = true;

  nix.settings.trusted-users = [
    "@admin"
  ];
  nix.configureBuildUsers = true;
  nix.extraOptions = ''
    auto-optimise-store = true
    experimental-features = nix-command flakes
  '';

  services.nix-daemon.enable = true;
  environment.variables = {
    AWS_PAGER = "";
  };
  environment.systemPackages = with pkgs; [
    wget
  ];
  nix.package = pkgs.nixUnstable;

}