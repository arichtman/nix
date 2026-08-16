{
  den.aspects.defaultUser = {
    nixos = {
      users.users.nixos = {
        isNormalUser = true;
        createHome = true;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJt9zJAxzYEK7Y2FYmwkT4cnYr/e4lO2w/ivNL74Pp6B"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMB0EONXbHFqCgHpvJDtFVrDyJeNVHb+XeweP+vYHf0F"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBxGxm6tCZlV3vJ6+yAkmQKcqVagfhgaf2aHzVQHvay+"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMSzoJ8/RDgYda2iQN1o8NmqbZnqQFnPLfuAYEaRIcGT"
        ];
        # TODO: Supposedly not required due to den.batteries.primary-user??
        extraGroups = ["wheel"];
      };
    };
  };
}
