{...}: {
  networking.hostName = "fat-controller";
  lab-node.enable = true;
  control-node.enable = true;
  virtual-node.enable = true;
  system.stateVersion = "23.11";
}
