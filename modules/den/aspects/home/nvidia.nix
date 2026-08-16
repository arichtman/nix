{
  den.aspects.home.nvidia = {
    pkgs,
    inputs,
    ...
  }: {
    homeManager = let
      # TODO: whyyyy
      # https://github.com/nix-community/nixGL/issues/114
      # nixGLWrap = pkg:
      #   pkgs.runCommand "${pkg.name}-nixgl-wrapper" {} ''
      #     mkdir $out
      #     ln -s ${pkg}/* $out
      #     rm $out/bin
      #     mkdir $out/bin
      #     for bin in ${pkg}/bin/*; do
      #      wrapped_bin=$out/bin/$(basename $bin)
      #      echo "exec ${lib.getExe pkgs.nixgl.auto.nixGLNvidia} $bin \$@" > $wrapped_bin
      #      chmod +x $wrapped_bin
      #     done
      #   '';
      # Ref: https://github.com/nix-community/nixGL/issues/16#issuecomment-903188923
      nixGLNvidiaScript = pkgs.writeShellScriptBin "nixGLNvidia" ''
        $(NIX_PATH=nixpkgs=${inputs.nixpkgs} nix-build ${inputs.nixgl} -A auto.nixGLNvidia --no-out-link)/bin/* "$@"
      '';
    in {
      home.packages = [
        nixGLNvidiaScript
        # TODO: review all this crap
        # https://github.com/nix-community/nixGL/issues/154
        # (nixGLWrap pkgs.alacritty)
      ];
    };
  };
}
