{
  den.aspects.k8s.debugTools = {pkgs}: {
    nixos.environment.systemPackages = [
      pkgs.ripgrep
      pkgs.kubernetes
      pkgs.bat
      pkgs.jq
      pkgs.yq-go
      pkgs.kubectl
      pkgs.k9s
      pkgs.kubernetes-helm
      pkgs.nerdctl
      pkgs.cri-tools
      pkgs.cni
    ];
  };
}
