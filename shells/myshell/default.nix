{
  pkgs,
  mkShell,
  ...
}: let
  # Ref: https://github.com/direnv/direnv/issues/73#issuecomment-2478178424
  mkScript = name: text: pkgs.writeShellScriptBin name text;
  scripts = [
    (mkScript "k" ''kubectl "$@"'')
  ];
  devEnvVars = {
    myvar = "myval";
  };
in
  mkShell (
    devEnvVars
    // {
      meta.platforms = ["aarch64-darwin" "x86_64-linux" "x86_64-darwin"];
      packages = with pkgs;
        [
          # Minimal development stuff
          git
          ripgrep
          jq
          yq
          helix
          pre-commit
          deploy-rs
          statix
          deadnix
          # Kubernetes stuff
          kubectl
          kubectx
          kubernetes-helm
          # Cilium
          cilium-cli
          hubble
          # Certificates and secrets
          xkcdpass
          step-cli
          openssl
          # Flake tooling
          snowfallorg.thaw
        ]
        ++ scripts;
      shellHook = ''
        pre-commit install --install-hooks
        echo "Entering the nix  Z O N E"
      '';
    }
  )
