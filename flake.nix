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
      #TODO: rework this https://nix.dev/anti-patterns/language#with-attrset-expression
      wsl-modules = with inputs; [
        nixos-wsl.nixosModules.wsl
        nixos-vscode-server.nixosModules.default
      ];
    in
    inputs.snowfall-lib.mkFlake {
      inherit inputs;
      src = ./.;

      package-namespace = "arichtman";

      #TODO: remove if I'm really done with VSCode
      channels-config.allowUnfree = false;

      overlays = with inputs; [
        poetry2nix.overlay
      ];

      alias.shells.default = "myshell";

      systems.hosts = {
        bruce-banner.modules = wsl-modules;

        work-laptop.modules = wsl-modules;
      };
    };
}
