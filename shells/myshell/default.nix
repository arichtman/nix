{
  pkgs,
  mkShell,
  ...
}:
mkShell {
  meta.platforms = ["aarch64-darwin" "x86_64-linux" "x86_64-darwin"];
  packages = with pkgs; [
    step-cli
    openssl
    git
    ripgrep
    helix
    pre-commit
    deploy-rs
  ];
  shellHook = ''
    pre-commit install --install-hooks
    echo "Entering the nix  Z O N E"
  '';
}
