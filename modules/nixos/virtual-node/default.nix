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
      # Bootloader.
      boot.loader.grub.enable = true;
      boot.loader.grub.device = "/dev/sda";
      # TODO: Work out how to import this from nixpkgs
      # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/profiles/qemu-guest.nix
      # imports = [
      #   (modulesPath + "/profiles/qemu-guest.nix")
      # ];

      boot.initrd.availableKernelModules = ["ata_piix" "uhci_hcd" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod"];
      boot.initrd.kernelModules = [];
      boot.kernelModules = [];
      boot.extraModulePackages = [];

      fileSystems."/" = {
        device = "/dev/sda1";
        fsType = "ext4";
        autoResize = true;
      };
    };
  }
