{
  den.aspects.defaultUser = {
    nixos = {
      users.users.nixos = {
        isNormalUser = true;
        # Not required due to den.batteries.primary-user
        # extraGroups = ["wheel"];
      };
    };
  };
}
