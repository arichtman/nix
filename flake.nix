{
  description = "Ariel's machine configs";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-release.url = "github:nixos/nixpkgs/release-24.11";

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

    yaml2nix = {
      url = "github:euank/yaml2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    valheim-server = {
      # url = "github:hamburger1984/valheim-server-flake";
      url = "github:arichtman/valheim-server-flake/patch-0-220-5";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs: let
    lib = inputs.snowfall-lib.mkLib {
      inherit inputs;
      src = ./.;
      snowfall.namespace = "arichtman";
    };
    # Bit of a bummer we can't use lib.arichtman here but Snowfall entirely needs to come out so...
    # Should yield [ "node-name" "other-node-name" ]
    nixosNodes = builtins.split "\n" (builtins.readFile ./nodes.txt);
    mkNixosConfiguration = name: {
      hostname = "${builtins.toString name}";
      profiles.system = {
        path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos inputs.self.nixosConfigurations."${builtins.toString name}";
      };
    };
    # Map should yield [ { "node-name" = { hostname = ...;};} {"other-node-name" = { hostname = ...;};}]
    # ListToAttrs should merge across the list elements into a single attrset...
    mkNixosNodeConfigurations = builtins.listToAttrs (builtins.map (n: {n = mkNixosConfiguration n;}) nixosNodes);
  in
    lib.mkFlake {
      channels-config.allowUnfree = true;

      systems.modules.darwin = with inputs; [
        mac-app-util.darwinModules.default
      ];
      systems.modules.nixos = [
        inputs.valheim-server.nixosModules.default
      ];
      overlays = with inputs; [
        nixgl.overlays.default
        snowfall-thaw.overlays.default
        valheim-server.overlays.default
      ];
      alias.shells = {
        default = "myshell";
      };

      deploy = {
        sshUser = "nixos";
        user = "root";
        remoteBuild = true;
        nodes = mkNixosNodeConfigurations;
        # TODO: DRY this up
        # nodes = {
        #   fat-controller = mkNixosConfiguration "fat-controller";
        #   patient-zero = mkNixosConfiguration "patient-zero";
        #   dr-singh = mkNixosConfiguration "dr-singh";
        #   smol-bat = mkNixosConfiguration "smol-bat";
        #   tweedledee = mkNixosConfiguration "tweedledee";
        #   tweedledum = mkNixosConfiguration "tweedledum";
        # };
      };

      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks inputs.self.deploy) inputs.deploy-rs.lib;
    };
}
