{
  # TODO: Move to dendritic pattern
  # Ref: https://github.com/mightyiam/dendritic
  # Ref: https://pc-hass.de/blog/dendritic-machines/
  description = "Ariel's machine configs";
  inputs = {
    # Ref: https://den.denful.dev/guides/migrate/
    den.url = "github:denful/den";
    import-tree.url = "github:denful/import-tree";
    flake-parts.url = "github:hercules-ci/flake-parts";

    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-versions = {
      url = "github:vic/nix-versions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixocaine = {
      url = "https://git.madhouse-project.org/iocaine/nixocaine/archive/main.tar.gz";
    };

    # TODO: move to official channels
    # Ref: https://chaos.social/@hexa/117111428896044773
    # TODO: use multiverse packages
    # Ref: https://fzakaria.com/2026/08/14/nixpkgs-multiverse-fast-mode
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };
  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {
      inherit inputs;
      # channels-config.allowUnfree = true;

      # systems.modules.nixos = [inputs.nixocaine.nixosModules.default];
      # overlays = with inputs; [
      #   nixgl.overlays.default
      #   nixocaine.overlays.default
      # ];
      # alias.shells = {
      #   default = "myshell";
      # };
    } (inputs.import-tree ./modules);
}
