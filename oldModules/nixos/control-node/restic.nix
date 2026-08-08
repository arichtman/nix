{
  config,
  lib,
  ...
}: {
  config.services.restic.backups.prune = lib.mkIf config.control-node.enable {
    environmentFile = "/var/lib/restic/s3-servers-australia";
    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 4"
      "--keep-monthly 1"
      "--group-by tags"
    ];
    repository = "s3:https://s3.si.servercontrol.com.au/backups";
  };
}
