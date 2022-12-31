{ pkgs, lib, ...}:
{
  nixpkgs.config.allowUnfree = true;

  nix.settings.trusted-users = [
    "@wheel"
  ];

  nix.extraOptions = ''
    auto-optimise-store = true
    experimental-features = nix-command flakes
  '';

  environment.variables = {
    AWS_PAGER = "";
  };

  environment.systemPackages = with pkgs; [
    wget
    curl
    direnv
    git
  ];

  environment.shellAliases = {
    ll = "ls -hAlLrt";
  };

}
