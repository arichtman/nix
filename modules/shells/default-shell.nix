{
  # imports = [inputs.den.flakeModule];
  # den.schema.flake-system.includes = [den.aspects.default-shell];

  # TODO: figure out what the fuck is going on here
  # den.aspects.default-shell = {
  #   devShells = {pkgs, ...}: {
  #     default = pkgs.mkShell {
  #       packages = [
  #         pkgs.just
  #       ];

  #       buildInputs = with pkgs; [
  #         prek
  #       ];
  #     };
  #   };
  # };
  perSystem = {pkgs, ...}: {
    devShells.default = let
      # Ref: https://github.com/direnv/direnv/issues/73#issuecomment-2478178424
      mkScript = name: text: pkgs.writeShellScriptBin name text;
      scripts = [
        (mkScript "k" ''kubectl "$@"'')
      ];
      devEnvVars = {
        myvar = "myval";
      };
    in
      pkgs.mkShell (devEnvVars
        // {
          buildInputs = with pkgs;
            [
              # Minimal development stuff
              git
              jujutsu
              ripgrep
              jq
              yq
              helix
              deploy-rs
              statix
              deadnix
              nixos-rebuild-ng
              # Kubernetes stuff
              kubectl
              kubernetes-helm
              kubelogin-oidc # Plugin for k8s auth
              # Cilium
              cilium-cli
              hubble
              # SPIFFE
              spire
              # Certificates and secrets
              xkcdpass
              step-cli
              openssl
              # Flake tooling
              nixtract
              # Pre-commit replacement
              prek
              # Experimental diff tool
              # TODO: figure out local packaging
              # arichtman.mamediff
              restic
            ]
            ++ scripts;
          meta.platforms = [
            "aarch64-darwin"
            "x86_64-linux"
          ];
          shellHook = ''
            prek install --install-hooks
            source <(kubectl completion zsh)
            echo "Entering the nix  Z O N E"
          '';
        });
  };
}
