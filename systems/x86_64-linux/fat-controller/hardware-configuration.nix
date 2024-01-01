{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot.initrd.availableKernelModules = ["ata_piix" "uhci_hcd" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod"];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/0951e51a-d458-48f0-89e2-698d21cb159b";
    fsType = "ext4";
  };
}
