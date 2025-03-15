{
  lib,
  rustPlatform,
  fetchFromGitHub,
  ...
}:
rustPlatform.buildRustPackage rec {
  pname = "mamediff";
  version = "v${src.rev}";
  src = fetchFromGitHub {
    owner = "sile";
    repo = pname;
    rev = "v0.2.1";
    hash = "sha256-kZeBPxg8B2tO4XFKxnWr2eIPgPssZTlKD8a/o3xCAOU=";
    # hash = lib.fakeHash;
  };
  # Ref: https://github.com/NixOS/nixpkgs/issues/61618#issuecomment-499377463
  # preConfigure = ''
  #   export HOME=`mktemp -d`
  # '';
  doCheck = false;
  cargoHash = "sha256-xScSh26YWNsoOxrj7/qsWGX1EMGdvazsRTZx6w1wLsE=";
  useFetchCargoVendor = true;
  meta = with lib; {
    mainProgram = pname;
    description = "A TUI editor for managing unstaged and staged Git diffs";
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
