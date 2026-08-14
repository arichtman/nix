{den, ...}: {
  den.aspects.controller = {
    includes = [
      den.aspects.controller.caddy
      den.aspects.controller.kanidm
      den.aspects.controller.garage
      den.aspects.controller.grafana
      den.aspects.controller.iocaine
      den.aspects.controller.forgejo
      den.aspects.controller.loki
      den.aspects.controller.prometheus
      den.aspects.controller.nix-serve
      den.aspects.controller.restic
      den.aspects.controller.step-ca
      den.aspects.controller.tempo
      den.aspects.controller.vaultwarden
      den.aspects.controller.website
    ];
  };
}
