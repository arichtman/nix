# Exposes flake apps under the name of each host / home for building with nh.
{
  den,
  lib,
  ...
}: {
  perSystem = {pkgs, ...}: {
    devShells.default = pkgs.mkShell {
      packages = [pkgs.cowsay];
    };
  };
}
