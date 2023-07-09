{
  pkgs,
  mkShell,
  arichtman,
  ...
}:
mkShell {
  nativeBuildInputs = with pkgs; [home-manager git ripgrep helix];
  packages = [pkgs.fd];
  shellHook = ''
    echo "Entering the nix  Z O N E"
  '';
}
