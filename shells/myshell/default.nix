{
  pkgs,
  mkShell,
  ...
}:
mkShell {
  meta.platforms = ["aarch64-darwin" "x86_64-linux" "x86_64-darwin"];
  packages = with pkgs; [
    # Minimal development stuff
    git
    ripgrep
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
  ];
  shellHook = ''
    pre-commit install --install-hooks
    echo "Entering the nix  Z O N E"
  '';
}
