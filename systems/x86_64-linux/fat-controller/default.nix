{...}: {
  networking.hostName = "fat-controller";
  virtual-node.enable = true;
  lab-node.enable = true;
  control-node.enable = true;
  system.stateVersion = "24.11";
  services = {
    # spire.trustDomain = "systems.richtman.au";
    # spire-server.enable = true;
    k8s.controller = true;
  };
}
