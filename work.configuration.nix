{ modulesPath, lib, pkgs, ... }: {
  imports = [ "${modulesPath}/virtualisation/amazon-image.nix" ];
  ec2.hvm = true;

  system.stateVersion = "22.11";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment = {
    systemPackages = lib.attrValues {
      inherit (pkgs)
        coreutils
        curl
        home-manager
        ripgrep
        wget
        git;
    };
  };

}
