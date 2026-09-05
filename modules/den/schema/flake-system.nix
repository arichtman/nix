{den, ...}: {
  # Required to apply aspect to flake
  den.schema.flake-system.includes = [
    den.aspects.packages.mamediff
    den.aspects.deployments
  ];
}
