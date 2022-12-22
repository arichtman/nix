{
  # inputs.nixpkgs.url = "github:nixos/nixpkgs";
  description = "NixOS system configurations";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-22.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-22.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, home-manager, ... } :
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
      };
    };
    lib = nixpkgs.lib;
    home-manager = home-manager;
  in {
    # homeManagerConfigurations = {  };
    devShells.${system}.default = pkgs.mkShell {
        packages = [ pkgs.terragrunt ];
      };
  };
}
