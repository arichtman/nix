{...}: {
  networking.hostName = "smol-bat";
  system.stateVersion = "23.05";
  lab-node.enable = true;
  physical-node = {
    volumes = {
      bootUuid = "D889-8B8F";
      rootUuid = "a90aba65-55f5-4f3c-bfb8-1b19869a538e";
    };
  };
  worker-node.enable = true;
}
