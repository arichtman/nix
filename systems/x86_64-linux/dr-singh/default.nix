{...}: {
  networking.hostName = "dr-singh";
  lab-node = {
    enable = true;
    volumes = {
      bootUuid = "6260-9E3B";
      rootUuid = "97d25a99-3d50-4bba-9872-7fb30a1f1706";
    };
  };
  worker-node.enable = true;
}
