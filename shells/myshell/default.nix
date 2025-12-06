{
  pkgs,
  mkShell,
  inputs,
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
      meta.platforms = ["aarch64-darwin" "x86_64-linux"];
      packages = with pkgs;
        [
          inputs.nix-versions.packages.${system}.nix-versions
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
          snowfallorg.thaw
          nixtract
          # Pre-commit replacement
          arichtman.prek
          # Experimental diff tool
          arichtman.mamediff
        ]
        ++ scripts;
      shellHook = ''
        prek install --install-hooks
        source <(kubectl completion zsh)
        echo "Entering the nix  Z O N E"
      '';
    }
  )
