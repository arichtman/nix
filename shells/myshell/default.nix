{
  pkgs,
  mkShell,
  # TODO: I'm not actually using any packages from this flake?
  # arichtman,
  ...
}:
mkShell {
  nativeBuildInputs = with pkgs; [home-manager git ripgrep helix pre-commit];
  packages = [pkgs.fd];
  shellHook = ''
    pre-commit install --install-hooks
    echo "Entering the nix  Z O N E"
  '';
}
