{
  description = "Nix system configurations";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = github:nix-community/home-manager;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl = {
      url = "github:nix-community/nixos-wsl";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, home-manager, ... }@inputs :
  let
    lib = nixpkgs.lib;
  in {
    nixosConfigurations = {
      temp-machine = lib.nixosSystem{
        system = "x86_64-linux";
        modules = [
          ./systems/x86_64-linux/temp-system/default.nix
        ];
      };
      main-laptop = lib.nixosSystem{
        system = "x86_64-linux";
        modules = with inputs; [
          nixos-wsl.nixosModules.wsl
          ./systems/x86_64-linux/main-laptop/default.nix
        ];
      };
    };

    homeConfigurations = {
      main-laptop = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [ ./homes/main-laptop.nix ];
      };
    };

  };
}
