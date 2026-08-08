{
  den,
  lib,
  ...
}: {
  den.schema.user = {
    includes = [
      den.batteries.define-user
      den.batteries.host-aspects
      (
        {user}:
          if user.isPrimaryUser
          then den.batteries.primary-user
          else {}
      )
      ];
      };
    }

