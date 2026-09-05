{inputs, ...}: {
  # TODO: not sure what this is doing
  imports = [inputs.den.flakeModule];
  den.default.nixos.system.stateVersion = "23.11";
}
