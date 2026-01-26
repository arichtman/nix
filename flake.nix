{
  description = "Ariel's machine configs";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    snowfall-lib = {
      url = "github:snowfallorg/lib/v3.0.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    snowfall-thaw = {
      url = "github:snowfallorg/thaw";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mac-app-util = {
      url = "github:hraban/mac-app-util";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-versions = {
      url = "github:vic/nix-versions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs: let
    lib = inputs.snowfall-lib.mkLib {
      inherit inputs;
      src = ./.;
      snowfall.namespace = "arichtman";
    };
    mkNixosConfiguration = name: {
      hostname = "${builtins.toString name}.systems.richtman.au";
      profiles.system = {
        path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos inputs.self.nixosConfigurations."${builtins.toString name}";
      };
    };
  in
    lib.mkFlake {
      channels-config.allowUnfree = true;

      systems.modules.darwin = with inputs; [
        mac-app-util.darwinModules.default
      ];
      overlays = with inputs; [
        nixgl.overlays.default
        snowfall-thaw.overlays.default
      ];
      alias.shells = {
        default = "myshell";
      };

      deploy = {
        sshUser = "nixos";
        user = "root";
        remoteBuild = true;
        # TODO: DRY this up
        nodes = {
          fat-controller = mkNixosConfiguration "fat-controller";
          patient-zero = mkNixosConfiguration "patient-zero";
          dr-singh = mkNixosConfiguration "dr-singh";
          smol-bat = mkNixosConfiguration "smol-bat";
          tweedledee = mkNixosConfiguration "tweedledee";
          tweedledum = mkNixosConfiguration "tweedledum";
        };
      };

      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks inputs.self.deploy) inputs.deploy-rs.lib;
    };
}
