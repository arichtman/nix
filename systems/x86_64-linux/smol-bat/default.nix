{...}: {
  networking.hostName = "smol-bat";
  lab-node = {
    enable = true;
    volumes = {
      bootUuid = "D889-8B8F";
      rootUuid = "a90aba65-55f5-4f3c-bfb8-1b19869a538e";
    };
  };
  worker-node.enable = true;
}
