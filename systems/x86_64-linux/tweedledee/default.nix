_: {
  networking.hostName = "tweedledee";
  system.stateVersion = "23.11";
  lab-node.enable = true;
  physical-node = {
    volumes = {
      bootUuid = "5B92-2D97";
      rootUuid = "fcbe8c60-dcf1-41dd-8734-faf546c5cd78";
    };
  };
  hardware.cpu.intel.updateMicrocode = true;
}
