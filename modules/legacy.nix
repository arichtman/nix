{den, ...}: {
  den.schema.host.includes = [
    (den.batteries.import-tree.provides.host ./hosts)
  ];
  den.schema.user.includes = [
    (den.batteries.import-tree.provides.user ./users)
  ];
}
