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
  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    forAllSystems = nixpkgs.lib.genAttrs [
      "x86_64-linux"
      "x86_64-darwin"
    ];
  in {
    nixosConfigurations = let
      # TODO: DRY this up
      system = "x86_64-linux";
      sys-config-file-path = sys: (name: ./systems/${sys}/${name}/default.nix);
      wsl-modules = with inputs; [
        nixos-wsl.nixosModules.wsl
        nixos-vscode-server.nixosModules.default
        ./systems/${system}/shared.nix
      ];
    in {
      bruce-banner = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = wsl-modules ++ [(sys-config-file-path system "bruce-banner")];
      };
      work-laptop = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = wsl-modules ++ [(sys-config-file-path system "work-laptop")];
      };
    };
    homeConfigurations = {
      "nixos@bruce-banner" = inputs.home-manager.lib.homeManagerConfiguration {
        # TODO: Should this be legacy packages?
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [./homes/bruce-banner.nix ./homes/shared.nix];
      };
      # https://github.com/nix-community/home-manager/issues/2942#issuecomment-1378627909
      "nixos@work-laptop" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
        modules = [./homes/work-laptop.nix ./homes/shared.nix];
      };
    };

    devShells = forAllSystems (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in
        import ./shell.nix {inherit pkgs;}
    );
  };
}
