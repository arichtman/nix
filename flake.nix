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

    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-darwin.url = "github:bandithedoge/nixpkgs-firefox-darwin";

    deploy-rs.url = "github:serokell/deploy-rs";
  };
  outputs = inputs: let
    #TODO: rework this https://nix.dev/anti-patterns/language#with-attrset-expression
    wsl-modules = with inputs; [
      nixos-wsl.nixosModules.wsl
    ];
    lib = inputs.snowfall-lib.mkLib {
      inherit inputs;
      src = ./.;
    };
  in
    lib.mkFlake {
      package-namespace = "arichtman";

      channels-config.allowUnfree = true;

      alias.shells = {
        default = "myshell";
      };

      systems.hosts.bruce-banner.modules = [inputs.nixos-wsl.nixosModules.wsl];

      # deploy = lib.mkDeploy { inherit (inputs) self; };
      deploy = {
        sshUser = "nixos";
        user = "root";
        nodes = {
          patient-zero = {
            remoteBuild = true;
            hostname = "patient-zero";
            profiles.system = {
              # user = "nixos";
              # TODO: See about self-referencing the name or make this a function
              path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos inputs.self.nixosConfigurations.patient-zero;
            };
          };
          dr-singh = {
            remoteBuild = true;
            hostname = "dr-singh";
            profiles.system = {
              path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos inputs.self.nixosConfigurations.dr-singh;
            };
          };
          smol-bat = {
            remoteBuild = true;
            hostname = "smol-bat";
            profiles.system = {
              path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos inputs.self.nixosConfigurations.smol-bat;
            };
          };
        };
      };

      # checks =
      #   builtins.mapAttrs
      #     (system: deploy-lib:
      #       deploy-lib.deployChecks inputs.self.deploy)
      #     inputs.deploy-rs.lib;
      # This is slightly adapted from deploy-rs repo. The above was verbatim from Jake's config. I think there's no difference?
      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks inputs.self.deploy) inputs.deploy-rs.lib;
    };
}
