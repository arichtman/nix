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
      boot.extraModulePackages = [];

      services.qemuGuest.enable = true;
      services.lvm.boot.thin.enable = true;
      # Required to respond to neighbor discovery protocol for IPv6 SLAAC
      # mDNS does the name-to-IP, ND does IP-to-MAC
      services.radvd = {
        enable = true;
        # TODO: Leftover from testing, remove before flight
        # prefix ::/64 {};
        # debugLevel = 4;
        config = ''
          interface ens18 {
            AdvSendAdvert on;
          };
        '';
      };
      fileSystems."/" = {
        device = "/dev/sda1";
        fsType = "ext4";
        autoResize = true;
      };
    };
  }
