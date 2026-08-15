{
  den,
  lib,
  ...
}: {
  den.schema.user = {
    includes = [
      den.batteries.define-user
      den.batteries.host-aspects
      den.batteries.primary-user
      (den.batteries.user-shell "zsh")
    ];
    # TODO: Might not be required
    classes = lib.mkDefault ["homeManager" "user"];
  };
}
