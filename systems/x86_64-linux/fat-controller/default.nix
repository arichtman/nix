{...}: {
  networking.hostName = "fat-controller";
  virtual-node.enable = true;
  lab-node.enable = true;
  control-node.enable = true;
  system.stateVersion = "24.11";
  services = {
    spire.trustDomain = "systems.richtman.au";
    spire-server.enable = true;
    spire-agent.enable = true;
    spire-agent.joinToken = "1cd5bbf1-e6e5-4cc8-9098-46dbb2f42755";
    k8s.controller = true;
  };
}
