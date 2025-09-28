{
  lib,
  fetchFromGitHub,
  pkgs,
  ...
}:
pkgs.buildGoModule rec {
  pname = "cluster-autoscaler";
  version = "1.33.1";
  modRoot = pname;

  src = fetchFromGitHub {
    owner = "kubernetes";
    repo = "autoscaler";
    rev = "v${version}";
    hash = "sha256-Gjw1dRrgM8D3G7v6WIM2+50r4HmTXvx0Xxme2fH9TlQ=";
  };

  vendorHash = "sha256-6hCgv2/8UIRHw1kCe3nLkxF23zE/7t5RDwEjSzX3pBQ=";

  meta = with lib; {
    description = "Autoscaling components for Kubernetes ";
    homepage = "https://github.com/${src.owner}/${src.repo}";
    license = licenses.apsl20;
    maintainers = with maintainers; [arichtman];
  };
}
