{...}: {
  networking.hostName = "patient-zero";
  system.stateVersion = "23.11";
  lab-node.enable = true;
  worker-node.enable = true;
  physical-node = {
    volumes = {
      bootUuid = "52CA-14B2";
      rootUuid = "1f83a0e2-f41c-4406-ac9d-36f9ffdf3345";
    };
  };
}
