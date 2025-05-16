# Ref: https://github.com/nix-community/home-manager/issues/4720#issuecomment-2885557184
{pkgs}:
with pkgs;
  alacritty.overrideAttrs (
    oldAttrs: {
      buildInputs = (oldAttrs.buildInputs or []) ++ [mesa.drivers libglvnd];
      postInstall =
        (oldAttrs.postInstall or "")
        + ''
          wrapProgram $out/bin/alacritty \
            --set LD_LIBRARY_PATH "${libglvnd}/lib:${mesa.drivers}/lib"
        '';
    }
  )
