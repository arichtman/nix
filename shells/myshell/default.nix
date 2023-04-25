{ pkgs, mkShell, arichtman, ... }:

mkShell {
  nativeBuildInputs = with pkgs; [ home-manager git ];
  packages = [ pkgs.fd ];
  shellHook = ''
    echo "Entering the nix  Z O N E"
    '';
 }
