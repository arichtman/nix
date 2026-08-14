{den, ...}: {
  den.aspects.controller = {
    includes = [
      den.aspects.controller.caddy
      den.aspects.controller.kanidm
      den.aspects.controller.garage
    ];
  };
}
