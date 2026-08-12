{
  self',
  lib,
  ...
}: {
  den.aspects.physical-node = {
    description = "Options for physical machines";
    volumes = {
      bootUuid = lib.mkOption {
        type = lib.types.str;
        description = "UUID for boot volume";
      };
      rootUuid = lib.mkOption {
        type = lib.types.str;
        description = "UUID for root volume";
      };
    };
    nixos = {host, ...}: let
      cfg = host.settings.volumes;
    in {
      # Bootloader
      boot = {
        loader = {
          grub.devices = [self'.nixos.filesystems."/boot".device];
          systemd-boot.enable = true;
          efi.canTouchEfiVariables = true;
        };

        # ---- HARDWARE -----
        # Note: This really only works for very homogenous machines.
        # Luckily all my physical nodes are about the same!

        initrd.availableKernelModules = ["xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod"];
        kernelModules = ["kvm-intel"];
      };

      fileSystems."/boot" = {
        device = "/dev/disk/by-uuid/${cfg.bootUuid}";
        fsType = "vfat";
      };
      fileSystems."/" = {
        device = "/dev/disk/by-uuid/${cfg.rootUuid}";
        fsType = "ext4";
      };

      networking.interfaces.eno1.wakeOnLan.enable = true;
      powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
      # hardware.cpu.intel.updateMicrocode = lib.mkDefault self'.config.hardware.enableRedistributableFirmware;
    };
  };
}
