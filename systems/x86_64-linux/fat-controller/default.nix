{...}: {
  networking.hostName = "fat-controller";
  lab-node.enable = true;
  master-node.enable = true;
  virtual-node.enable = true;
  system.stateVersion = "23.11";
}