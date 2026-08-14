{den, ...}: {
  den.aspects.controller = {
    includes = [
      den.aspects.controller.caddy
      den.aspects.controller.kanidm
      den.aspects.controller.garage
      den.aspects.controller.iocaine
      den.aspects.controller.forgejo
    ];
  };
}
