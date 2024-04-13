{
  description = "Ariel's machine configs";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixgl.url = "github:nix-community/nixGL";

    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = inputs: let
    lib = inputs.snowfall-lib.mkLib {
      inherit inputs;
      src = ./.;
    };
  in
    lib.mkFlake {
      package-namespace = "arichtman";

      channels-config.allowUnfree = true;

      overlays = with inputs; [
        nixgl.overlays.default
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
          fat-controller = {
            hostname = "fat-controller";
            profiles.system = {
              path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos inputs.self.nixosConfigurations.fat-controller;
            };
          };
          mum = {
            hostname = "mum";
            profiles.system = {
              path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos inputs.self.nixosConfigurations.mum;
            };
          };
          patient-zero = {
            hostname = "patient-zero";
            profiles.system = {
              # TODO: See about self-referencing the name or make this a function
              path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos inputs.self.nixosConfigurations.patient-zero;
            };
          };
          dr-singh = {
            hostname = "dr-singh";
            profiles.system = {
              path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos inputs.self.nixosConfigurations.dr-singh;
            };
          };
          smol-bat = {
            hostname = "smol-bat";
            profiles.system = {
              path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos inputs.self.nixosConfigurations.smol-bat;
            };
          };
        };
      };

      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks inputs.self.deploy) inputs.deploy-rs.lib;
    };
}
