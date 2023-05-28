{
  description = "Ariel's machine configs";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    snowfall-lib = {
      url = "github:snowfallorg/lib/feat/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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

    poetry2nix = {
      url = "github:nix-community/poetry2nix";
    };
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    firefox-darwin.url = "github:bandithedoge/nixpkgs-firefox-darwin";
  };
  outputs = inputs:
  let
    lib = inputs.snowfall-lib.mkLib {
      inherit inputs;
      src = ./.;
    };
    wsl-modules = with inputs; [
      nixos-wsl.nixosModules.wsl
      nixos-vscode-server.nixosModules.default
    ];
  in
    lib.mkFlake {
      inherit inputs;
      lib = inputs.nixpkgs.lib;
      overlay-package-namespace = "arichtman";
      src = ./.;
      channels-config.allowUnfree = false; #TODO: remove if I'm really done with VSCode
      #TODO: rework this https://nix.dev/anti-patterns/language#with-attrset-expression
      overlays = with inputs; [
          poetry2nix.overlay
        ];
      outputs-builder = channels: {
        devShells = {
          default = "myshell";
        };
      };
      systems.modules = with inputs; [
        home-manager.nixosModules.home-manager
      ];
      systems.hosts.bruce-banner.modules = wsl-modules;
      systems.hosts.work-laptop.modules = wsl-modules;
      systems.hosts.macbookpro.modules = with inputs; [
        #TODO: remove arichtman references if unused
        # arichtman.my_home
        # my_home
        # arichtman
        # arichtman.default-home
        darwin.darwinModules.simple
        home-manager.darwinModule
        {nixpkgs.overlays = [firefox-darwin.overlay];}
      ];
  };
}
