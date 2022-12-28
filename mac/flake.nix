# flake.nix
{
  description = "Ariel's machine configs";
    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-22.11-darwin";
        nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

        darwin.url = "github:lnl7/nix-darwin";
        darwin.inputs.nixpkgs.follows = "nixpkgs-unstable";

        home-manager.url = "github:nix-community/home-manager";
        home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";

        nixpkgs-firefox-darwin.url = "github:bandithedoge/nixpkgs-firefox-darwin";
    };

    outputs = { self, darwin, nixpkgs, home-manager, ... }@inputs:
       let
         inherit (darwin.lib) darwinSystem;
       in
       {
        darwinConfigurations = {
          macbookpro = darwinSystem {
            system = "x86_64-darwin";
            modules = [
                { nixpkgs.overlays = [ inputs.nixpkgs-firefox-darwin.overlay ]; }
                ./darwin-configuration.nix
                home-manager.darwinModule {
                  home-manager = {
                    useGlobalPkgs = true;
                    useUserPackages = true;
                    users.arichtman = { imports = [ ./home.nix ]; };
                };
              }
            ];
        };
    };
  };
}
