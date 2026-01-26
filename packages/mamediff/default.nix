{
  lib,
  rustPlatform,
  fetchFromGitHub,
  ...
}:
rustPlatform.buildRustPackage rec {
  pname = "mamediff";
  version = src.rev;
  src = fetchFromGitHub {
    owner = "sile";
    repo = pname;
    rev = "v0.5.1";
    hash = "sha256-vSk31t4iXdC4ZjBB45rQkfD6nPZM6/p6xz5fIHDcCcg=";
  };
  # Possibly not required but makes it work for now
  doCheck = false;
  cargoHash = "sha256-mZ7IZFn8pCs7cu1lkHMFbrWbctxbrst/QdNv9jrYq3Y=";
  meta = with lib; {
    mainProgram = pname;
    description = "A TUI editor for managing unstaged and staged Git diffs";
    homepage = "https://github.com/${src.owner}/${pname}";
    changelog = "${meta.homepage}/releases/tag/${src.rev}";
    license = with licenses; [
      mit
    ];
    maintainers = with maintainers; [
      arichtman
    ];
  };
}
