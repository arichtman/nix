{
  den.aspects.defaultUser = {
    nixos = {
      users.users.nixos = {
        isNormalUser = true;
        extraGroups = ["wheel"];
      };
    };
  };
}
