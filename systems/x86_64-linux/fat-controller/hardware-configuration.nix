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
    device = "/dev/disk/by-uuid/bdef5c05-ae5b-49f0-b2c4-27f0c57e82c5";
    fsType = "ext4";
  };
}
