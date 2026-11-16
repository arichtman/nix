{
  den.aspects.controller.nix-serve = {
    nixos = {
      services = {
        nix-serve = {
          enable = true;
          openFirewall = true;
          secretKeyFile = "/var/lib/nix-serve/cache-private-key.pem";
          # Ref: https://github.com/NixOS/nixpkgs/issues/526317
          bindAddress = "";
        };
      };
    };
  };
}
