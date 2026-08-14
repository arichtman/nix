{
  den.aspects.controller.restic = {
    nixos.services.restic.backups.prune = {
      environmentFile = "/var/lib/restic/s3-servers-australia";
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 4"
        "--keep-monthly 1"
        "--group-by tags"
      ];
      repository = "s3:https://s3.si.servercontrol.com.au/backups";
    };
  };
}
