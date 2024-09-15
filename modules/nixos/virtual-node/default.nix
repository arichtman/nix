{
  config,
  lib,
  ...
}: let
  cfg = config.virtual-node;
in
  with lib; {
    options.virtual-node = with types; {
      enable = mkOption {
        type = bool;
        description = "Virtualized node system configuration";
        default = false;
      };
    };
    config = mkIf cfg.enable {
      boot.loader.grub.enable = true;
      boot.loader.grub.device = "/dev/sda";

      boot.initrd.availableKernelModules = ["ata_piix" "uhci_hcd" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod"];
      boot.initrd.kernelModules = [
        "dm-snapshot" # Ref: https://nixos.wiki/wiki/LVM
      ];
      boot.kernelModules = [];
      boot.extraModulePackages = [];

      services.qemuGuest.enable = true;
      services.lvm.boot.thin.enable = true;
      fileSystems."/" = {
        device = "/dev/sda1";
        fsType = "ext4";
        autoResize = true;
      };
    };
  }
