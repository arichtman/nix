{
  lib,
  rustPlatform,
  fetchFromGitHub,
  ...
}:
rustPlatform.buildRustPackage rec {
  pname = "prek";
  version = src.rev;
  src = fetchFromGitHub {
    owner = "j178";
    repo = pname;
    rev = "v0.2.2";
    hash = "sha256-hiGfbrE/I0Gmp5G8BOlTnWc8+XeuDc7yyBaw2AfeW40=";
  };
  # Ref: https://github.com/NixOS/nixpkgs/issues/61618#issuecomment-499377463
  doCheck = false; # Read only FS
  useNextest = true;
  cargoHash = "sha256-8fg80Rluea3MgzHZYhik26UxzpoNcsT8PZp+NqTmhcY=";
  meta = with lib; {
    description = "⚡ Better `pre-commit`, re-engineered in Rust";
    homepage = "https://github.com/${src.owner}/${pname}";
    changelog = "${meta.homepage}/releases/tag/${version}";
    license = with licenses; [
      mit
    ];
    maintainers = with maintainers; [
      arichtman
    ];
  };
}
