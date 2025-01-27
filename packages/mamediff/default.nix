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
    rev = "0.1.2";
    hash = "sha256-mx8oqBPMSJNFZTBaWpmCkepe2A0pHulUQ82mk6DLkL4=";
    # hash = lib.fakeHash;
  };
  # Ref: https://github.com/NixOS/nixpkgs/issues/61618#issuecomment-499377463
  # preConfigure = ''
  #   export HOME=`mktemp -d`
  # '';
  doCheck = false;
  cargoHash = "sha256-66aRYlS3AmMHJ3Rq9ZopLEWhEGw5UEAhv1+rUYcJaB4=";
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
