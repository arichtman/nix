{ modulesPath, ... }:
let
  # nixos-wsl = import ./nixos-wsl;
in
{
  imports = [
    nixos-wsl.nixosModules.wsl
  ];
}