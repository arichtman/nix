{
  lib,
  rustPlatform,
  fetchFromGitHub,
  ...
}:
rustPlatform.buildRustPackage rec {
  pname = "prefligit";
  version = "v0.0.10";
  # Required to avoid Failed to create test bucket: Custom { kind: PermissionDenied, error: Error { kind: CreateDir, source: Os { code: 13, kind: PermissionDenied, message: "Permission denied" }, path: "/homeless-shelter/.local/share/prefligit/tests" } }
  doCheck = false;
  src = fetchFromGitHub {
    owner = "j178";
    repo = pname;
    rev = version;
    hash = "sha256-U2Z3R4MfBxjecDo3foSOQaNgMilOqx5JAaj04SM6jMk=";
  };
  cargoHash = "sha256-CcGqEcZi1u2KJpEnkkizt+vjG3D0Zh7AWl8u04+ytvo=";
  meta = with lib; {
    description = "pre-commit re-implemented in Rust";
    homepage = "https://github.com/j178/prefligit";
    changelog = "https://github.com/j178/prefligit/releases/tag/${version}";
    license = with licenses; [
      mit
    ];
    maintainers = with maintainers; [
      arichtman
    ];
    mainProgram = "prefligit";
  };
}
