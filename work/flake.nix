{
  # inputs.nixpkgs.url = "github:nixos/nixpkgs";
  description = "NixOS system configurations";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-22.11";
    # Unclear why it doesn't accept this format
    home-manager = {
      url = "github:nix-community/home-manager";
      # url = "github:nix-community/home-manager/release-22.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # home-manger.url = "github:nix-community/home-manager/release-22.05";
    # home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # nixos-wsl.url = "github:nix-community/nixos-wsl/22.05-5c211b47";
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
