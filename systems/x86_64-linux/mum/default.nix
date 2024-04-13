{...}: {
  networking.hostName = "mum";
  lab-node.enable = true;
  worker-node.enable = true;
  virtual-node.enable = true;
  system.stateVersion = "23.11";
}
