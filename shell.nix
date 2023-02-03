{pkgs ? (import ./nixpkgs.nix) {}}: {
  default = pkgs.mkShell {
    # Enable experimental features without having to specify the argument
    NIX_CONFIG = "experimental-features = nix-command flakes";
    nativeBuildInputs = with pkgs; [nix home-manager git];
    packages = [pkgs.fd];
    shellHook = ''
      echo "Entering the nix Z O N E"
    '';
  };
}
