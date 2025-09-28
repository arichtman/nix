{
  lib,
  fetchFromGitHub,
  pkgs,
  ...
}:
# TODO: This is building pet only. Not sure why only some of my config like modRoot seems to be taking
# Ref: https://nixos.wiki/wiki/Go
pkgs.buildGoModule {
  pname = "cluster-autoscaler";
  version = "1.33.1";
  # modRoot = "cluster-autoscaler";
  # sourceRoot = "autoscaler";

  # doCheck = false;
  # src = "./foo";
  src = fetchFromGitHub {
    owner = "kubernetes";
    repo = "autoscaler";
    rev = "cluster-autoscaler-1.33.1";
    hash = "sha256-Gjw1dRrgM8D3G7v6WIM2+50r4HmTXvx0Xxme2fH9TlQ=";
  };
  # } + "/${pname}";

  vendorHash = "sha256-6hCgv2/8UIRHw1kCe3nLkxF23zE/7t5RDwEjSzX3pBQ=";

  meta = with lib; {
    description = "Autoscaling components for Kubernetes ";
    homepage = "https://github.com/kubernetes/autoscaler";
    license = licenses.apsl20;
    maintainers = with maintainers; [arichtman];
  };
}
