{...}: {
  networking.hostName = "fat-controller";
  virtual-node.enable = true;
  lab-node.enable = true;
  control-node.enable = true;
  flannel-node.enable = true;
  system.stateVersion = "23.11";
}
