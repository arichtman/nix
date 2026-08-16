{...}: {
  networking.hostName = "fat-controller";
  system.stateVersion = "24.11";
  services = {
    spire-server.enable = true;
    spire-agent.enable = false; # Needs a new join token on deployment
    spire-agent.joinToken = "1cd5bbf1-e6e5-4cc8-9098-46dbb2f42755";
  };
}
