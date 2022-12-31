{
  description = "Ariel's machine configs";
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

    nixos-vscode-server = {
      url = "github:msteen/nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  # TODO: What's this @inputs thing anyways?
  outputs = { self, nixpkgs, ... }@inputs :
  let

  in {
    nixosConfigurations = {
      bruce-banner = nixpkgs.lib.nixosSystem{
        system = "x86_64-linux";
        modules = with inputs;[
          nixos-wsl.nixosModules.wsl
          nixos-vscode-server.nixosModules.default
          ./configuration.nix
        ];
      };
    };
    homeConfigurations."nixos@bruce-banner" = inputs.home-manager.lib.homeManagerConfiguration {
      # TODO: Should this be legacy packages?
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [ ./home.nix ];
    };
  };
}