{...}: let
in {
  networking.hostName = "patient-zero";
  lab-node = {
    enable = true;
    volumes = {
      bootUuid = "52CA-14B2";
      rootUuid = "1f83a0e2-f41c-4406-ac9d-36f9ffdf3345";
    };
  };
}
