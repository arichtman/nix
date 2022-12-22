{
  # inputs.nixpkgs.url = "github:nixos/nixpkgs";
  description = "NixOS system configurations";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-22.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-22.11";
      # Since we've pinned both our releases we can override the nixpkgs that home-manager pulls, thus reducing waste.
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  # Outputs is actually a function that takes in the input flakes/modules
  outputs = { self, nixpkgs, home-manager, ... } :
  let
    system = "x86_64-linux";
    # inherit modulesPath;
    pkgs = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
      };
    };
    lib = nixpkgs.lib;
    home-manager = home-manager;
  in {
    # inherit modulesPath;
    packages.${system} = {
      default = [ pkgs.terragrunt ];
      nixosConfigurations = {
        dev-machine = lib.nixosSystem {
          inherit system;
          modules = [
            # "${builtins.modulesPath}/virtualisation/amazon-image.nix"
            # "${modulesPath}/virtualisation/amazon-image.nix"
            home-manager.nixosModules.home-manager
          ];
        };
      };
    };

  nixosConfigurations.ec2 = lib.nixosSystem {
    inherit system;
    modules = [
      ./configuration.nix
    ];
  };

    # homeManagerConfigurations = {  };
    homeConfigurations = {
      nixos = home-manager.lib.homeManagerConfiguration {
        system = "x86_64-linux";
        homeDirectory = "/home/nixos";
        username = "nixos";
        stateVersion = "22.11";
      };
    };
    devShells.${system} = {
      default = pkgs.mkShell {
          packages = [ pkgs.terragrunt ];
        };
      imported = import ./shell.nix { inherit pkgs; };
    };
  };
}
