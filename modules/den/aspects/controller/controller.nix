{den, ...}: {
  den.aspects.controller = {
    includes = [
      den.aspects.controller.caddy
    ];
  };
}
