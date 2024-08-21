{
  pkgs,
  inputs,
  ...
}: let
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
in {
  programs = {
    # TODO: Work out if there's a config option that fixes this workaround
    # https://github.com/NixOS/nix/issues/3616#issuecomment-1655785404
    # https://github.com/NixOS/nix/issues/1577#issuecomment-388029166
    # https://github.com/NixOS/nix/issues/1577#issuecomment-1087605120
    # https://github.com/NixOS/nix/issues/3317#issuecomment-997177304
    bash.initExtra = ''
      [[ ! $(command -v nix) && -e "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]] && source "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
    '';
  };
  home.packages = let
    # Ref: https://github.com/nix-community/nixGL/issues/16#issuecomment-903188923
    nixGLNvidiaScript = pkgs.writeShellScriptBin "nixGLNvidia" ''
      $(NIX_PATH=nixpkgs=${inputs.nixpkgs} nix-build ${inputs.nixgl} -A auto.nixGLNvidia --no-out-link)/bin/* "$@"
    '';
  in [
    nixGLNvidiaScript
    # https://github.com/nix-community/nixGL/issues/154
    # (nixGLWrap pkgs.alacritty)
  ];
  personal-machine.enabled = true;
  default-home = {
    username = "arichtman";

    git = {
      email = "10679234+arichtman@users.noreply.github.com";
      username = "Ariel Richtman";
    };
    isThatOneWeirdMachine = true;
  };
}
